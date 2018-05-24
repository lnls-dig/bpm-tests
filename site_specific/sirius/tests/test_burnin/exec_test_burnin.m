function raw_results = exec_test_burnin(config_path, crate_number, log_filename)

if nargin < 3 || isempty(log_filename)
    fid_logfile = [];
else
    fid_logfile = fopen(log_filename, 'a');
end
fid = [1 fid_logfile];

% Load test parameters
config_filename = fullfile(config_path, 'burnin', 'burnin.cfg');
test_config = readstrlines(config_filename, '%s %s');
for i=1:size(test_config{1},1)
    eval([test_config{1}{i} '=' test_config{2}{i} ';']);
end

checksw_param.swharm_threshold = swharm_threshold;

checkamp_param.monit_amp_goal = monit_amp_goal;
checkamp_param.monit_amp_var_tol_pct = monit_amp_var_tol_pct;
checkamp_param.graph_nsamples = graph_nsamples;
checkamp_param.period_ms = period_ms;

checkatt_param.max_att = max_att;
checkatt_param.delta_att = delta_att;
checkatt_param.navg_monit_amp = navg_monit_amp;
checkatt_param.period_ms = period_ms;
checkatt_param.monit_amp_pv_names = monit_amp_pv_names;

test_names = {'EPICS AFC', 'EPICS RFFE', 'Amplitude', 'Att./Cable', 'Ref. clock', 'Switching'};
ntests = length(test_names);


% Apply configuration and check which BPMs are alive
logtext(fid, 'trace', 'Applying BPM and Photon BPM configurations and checking active units...');
[bpm_ok_array, bpm_set] = bpm_config(config_path, crate_number);
rfbpms = bpm_set{3};
results = nan(length(rfbpms),ntests);
results(:,1) = double(bpm_ok_array{3});
results(:,2) = double(bpm_ok_array{4});
afc_ok = results(:,1) == 1;
rffe_ok = results(:,2) == 1;

% Start quick amplitude test
logtext(fid, 'trace', 'Starting quick amplitude test...');
results(:,3) = bpm_checkamp_quick(rfbpms, checkamp_param, afc_ok);

% Start BPM Attenuator Test
logtext(fid, 'trace', 'Checking BPM attenuators or cables or RFFE/AFC correspondence...');
results(:,4) = bpm_checkatt(rfbpms, checkatt_param, afc_ok & rffe_ok);

% Start BPM Reference Clock Test
logtext(fid, 'trace', 'Checking if BPM clocks are locked to the reference clock sent through the crate backplane...');
results(:,5) = bpm_islocked(rfbpms, afc_ok);
refclk_ok = results(:,5) == 1;

% Start BPM Switching Test
logtext(fid, 'trace', 'Checking if switching works properly on locked BPMs...');
results(:,6) = bpm_checksw(rfbpms, checksw_param, refclk_ok & afc_ok);

disp_results(results, rfbpms, test_names);

% Start Monitoring Amplitude test
logtext(fid, 'trace', 'Starting Amplitude test...');
[X,Y,pv_names] = bpm_checkamp(rfbpms, checkamp_param, afc_ok & rffe_ok & refclk_ok);

raw_results.monit_amp = Y;
raw_results.t = X*period_ms/1e3;
raw_results.pv_names = pv_names;

if ~isempty(fid_logfile)
    fclose(fid_logfile);
end

raw_results.bpms = rfbpms;
raw_results.results = results;
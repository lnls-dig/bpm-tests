function results = exec_test_burnin(config_path, crate_number, log_filename, previous_test_run)

waittime_between_experiments = 5;

if nargin < 3 || isempty(log_filename)
    fid_logfile = [];
else
    fid_logfile = fopen(log_filename, 'a');
end
fid = [1 fid_logfile];

if nargin < 4 || isempty(previous_test_run)
    previous_raw_results = [];
else
    [pathstr, previous_test_run] = fileparts(previous_test_run);    
    if isempty(pathstr)
        pathstr = fileparts(log_filename);
    end
    previous_test_run = fullfile(pathstr, [previous_test_run '.mat']);
    if ~exist(previous_test_run, 'file')
        logtext(fid, 'error', sprintf('Could not find data from previous test in ''%s''. Aborting...', previous_test_run), true);
        results = [];
        return;
    end        
    load(previous_test_run, 'results');
    if ~exist('results', 'var') || isempty(results)
        logtext(fid, 'error', 'The specified previous test has not generated usable data. Aborting...', true);
        results = [];
        return;
    else
        previous_raw_results = results;
    end
end

% Load test parameters
config_filename = fullfile(config_path, 'burnin', 'burnin.cfg');
test_config = readstrlines(config_filename, '%s %s');
for i=1:size(test_config{1},1)
    eval([test_config{1}{i} '=' test_config{2}{i} ';']);
end

checksw_param.swharm_threshold = swharm_threshold;

if isempty(previous_raw_results)
    checkamp_param.monit_amp_var_tol_pct = monit_amp_var_tol_pct;
    checkamp_param.monit_amp_goal = monit_amp_goal;
else
    bpm_amp_ok_previous = previous_raw_results.pass_fail(:,3) == 1;
    namps = size(previous_raw_results.raw{3}.amp,2);
    checkamp_param.monit_amp_var_tol_pct = monit_amp_var_tol_pct_rerun;
    checkamp_param.monit_amp_goal = repmat(monit_amp_goal, 1, namps);
    amp_ok_previous = false(1,namps);
    for i=1:4
        amp_ok_previous(1,i:4:namps) = bpm_amp_ok_previous;
    end    
    checkamp_param.monit_amp_goal(amp_ok_previous) = previous_raw_results.raw{3}.amp(amp_ok_previous);
end
checkamp_param.graph_nsamples = graph_nsamples;
checkamp_param.period_ms = period_ms;

checkatt_param.max_att = max_att;
checkatt_param.delta_att = delta_att;
checkatt_param.navg_monit_amp = navg_monit_amp;
checkatt_param.period_ms = period_ms;
checkatt_param.monit_amp_pv_names = monit_amp_pv_names;

test_names = {'EPICS AFC', 'EPICS RFFE', 'Amplitude', 'Att./Cable', 'Ref. clock', 'Switching'}; % TODO: get these names from the test itself (from function output argument)
ntests = length(test_names);


% Apply configuration and check which BPMs are alive
logtext(fid, 'trace', 'Applying BPM and Photon BPM configurations and checking active units...');
[bpm_ok_array, bpm_set] = bpm_config(config_path, crate_number);
rfbpms = bpm_set{3};
pass_fail = nan(length(rfbpms),ntests);
pass_fail(:,1) = double(bpm_ok_array{3});
pass_fail(:,2) = double(bpm_ok_array{4});
afc_ok = pass_fail(:,1) == 1;
rffe_ok = pass_fail(:,2) == 1;
pause(waittime_between_experiments);

% Start quick amplitude test
logtext(fid, 'trace', 'Starting quick amplitude test...');
[pass_fail(:,3), raw{3}] = bpm_checkamp_quick(rfbpms, checkamp_param, afc_ok);
amp_ok = pass_fail(:,3) == 1;

% Start BPM Attenuator Test
logtext(fid, 'trace', 'Checking BPM attenuators or cables or RFFE/AFC correspondence...');
[pass_fail(:,4), raw{4}] = bpm_checkatt(rfbpms, checkatt_param, afc_ok & rffe_ok);
pause(waittime_between_experiments);

% Start BPM Reference Clock Test
logtext(fid, 'trace', 'Checking if BPM clocks are locked to the reference clock sent through the crate backplane...');
[pass_fail(:,5), raw{5}] = bpm_islocked(rfbpms, afc_ok);
refclk_ok = pass_fail(:,5) == 1;
pause(waittime_between_experiments);

% Start BPM Switching Test
logtext(fid, 'trace', 'Checking if switching works properly...');
[pass_fail(:,6), raw{6}] = bpm_checksw(rfbpms, checksw_param, afc_ok & amp_ok);
pause(waittime_between_experiments);

% BPMs which passed all tests
bpm_ok = all(pass_fail,2);

logtext(fid, 'info', 'Pass-fail test results:');

disp_results(pass_fail, rfbpms, test_names, fid);

% Start Monitoring Amplitude test
logtext(fid, 'trace', 'Starting Amplitude test...');
[~, raw{7}] = bpm_checkamp(rfbpms, checkamp_param, afc_ok, bpm_ok);

logtext(fid, 'trace', 'DONE! All tests have been performed.');
if ~isempty(fid_logfile)
    fclose(fid_logfile);
end

results.test_names = test_names;
results.bpms = rfbpms;
results.pass_fail = pass_fail;
results.raw = raw;
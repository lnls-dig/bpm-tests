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

% Apply configuration and check which BPMs are alive
logtext(fid, 'trace', 'Applying BPM and Photon BPM configurations and checking active units...');
[bpm_ok1, bpm_set] = bpm_config(config_path, crate_number);
bpms = bpm_set{3}(bpm_ok1{3}); % only RF BPMs

if ~isempty(bpms)
    % Start quick amplitude test
    bpm_ok2 = bpm_checkamp_quick(bpms, checkamp_param);
    
    % Start BPM Attenuator Test
    logtext(fid, 'trace', 'Checking BPM attenuators or cables or RFFE/AFC correspondence...');
    [bpm_ok3, bpm_ok4] = bpm_checkatt(bpms, checkatt_param);
    
    % Start BPM Reference Clock Test
    logtext(fid, 'trace', 'Checking if BPM clocks are locked to the reference clock sent through the crate backplane...');
    bpm_ok5 = bpm_islocked(bpms);
    
    bpms_locked = bpms(bpm_ok5);
    
    if ~isempty(bpms_locked)
        % Start BPM Switching Test
        logtext(fid, 'trace', 'Checking if switching works properly on locked BPMs...');
        
        bpm_ok6 = bpm_checksw(bpms_locked, checksw_param);
        
        % Start Monitoring Amplitude test
        logtext(fid, 'trace', 'Starting Amplitude test...');
        [X,Y,pv_names] = bpm_checkamp(bpms_locked, checkamp_param);
        
        raw_results.monit_amp = Y;
        raw_results.t = X*period_ms/1e3;
        raw_results.pv_names = pv_names;
        
        input('Done! Press <ENTER> to save data.');
    else
        logtext(fid, 'warning', 'Skipping switching and amplitude tests since there are no locked BPMs...', true);
        bpm_ok6 = [];
    end
else
    bpms_locked = [];
    bpm_ok2 = [];
    bpm_ok3 = [];
    bpm_ok4 = [];
    bpm_ok5 = [];
    bpm_ok6 = [];
end

if ~isempty(fid_logfile)
    fclose(fid_logfile);
end

raw_results.bpm_set = bpm_set;
raw_results.bpms = bpms;
raw_results.bpms_locked = bpms_locked;
raw_results.bpm_ok1 = bpm_ok1;
raw_results.bpm_ok2 = bpm_ok2;
raw_results.bpm_ok3 = bpm_ok3;
raw_results.bpm_ok4 = bpm_ok4;
raw_results.bpm_ok5 = bpm_ok5;
raw_results.bpm_ok6 = bpm_ok6;
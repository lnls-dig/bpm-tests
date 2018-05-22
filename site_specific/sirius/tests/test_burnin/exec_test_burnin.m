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

% Apply configuration and check which BPMs are alive
logtext(fid, 'trace', 'Applying BPM and Photon BPM configurations and checking active units...');
r = configbpm(config_path, crate_number, log_filename);
bpms = r.bpms;

% Start BPM Reference Clock Test
fid = 1;
if ~isempty(bpms)
    logtext(fid, 'trace', 'Checking if BPM clocks are locked to the reference clock sent through the crate backplane...');
    [bpms_locked, bpms_notlocked, bpms_inactive] = bpm_islocked(bpms);
    if isempty(bpms_notlocked)
        logtext(fid, 'info', sprintf('All active BPMs are locked to the reference clock.'), true);
    else
        logtext(fid, 'error', sprintf('Some BPMs are not locked to the reference clock...'), true);
        for i=1:length(bpms_notlocked)
            logtext(fid, 'error', sprintf('Not locked BPM: %s', bpms_notlocked{i}), true);
        end
    end
else
    bpms_locked = [];
    bpms_notlocked = [];
end

if ~isempty(bpms_locked)
    % Start BPM Switching Test
    logtext(fid, 'trace', 'Checking if switching works properly on locked BPMs...');

    [bpms_switching, bpms_notswitching] = bpm_checksw(bpms_locked, checksw_param);
    if isempty(bpms_notswitching)
        logtext(fid, 'info', sprintf('All locked BPMs are switching properly.'),true);
    else
        logtext(fid, 'error', sprintf('Some BPMs are not switching properly...'), true);
        for i=1:length(bpms_notswitching)
            logtext(fid, 'error', sprintf('Not switching: %s', bpms_notswitching{i}),true);
        end
    end

    % Start Monitoring Amplitude test
    fprintf('\n');
    input('Ready to start Monitoring Amplitude Test. Press <ENTER> to continue...');
    [X,Y,pv_names] = bpm_checkamp(bpms, checkamp_param);
else
    logtext(fid, 'warning', 'Skipping switching and amplitude tests since there are no locked BPMs...', true);
    Y = [];
    X = [];
    pv_names = [];
    bpms_switching = [];
    bpms_notswitching = [];
end

raw_results.bpms_locked = bpms_locked;
raw_results.bpms_notlocked = bpms_notlocked;
raw_results.bpms_switching = bpms_switching;
raw_results.bpms_notswitching = bpms_notswitching;
raw_results.monit_amp = Y;
raw_results.t = X*period_ms/1e3;
raw_results.pv_names = pv_names;
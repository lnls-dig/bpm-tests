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
[bpm_ok_array, bpm_set] = bpm_config(config_path, crate_number);
rfbpms = bpm_set{3};

x = false(length(rfbpms),1);

idx_rfbpm_afc_comm_ok = find(bpm_ok_array{3});
idx_rfbpm_rffe_comm_ok = find(bpm_ok_array{4});

bpm_ok1 = x;
bpm_ok1(idx_rfbpm_afc_comm_ok) = true;

bpm_okx = x;
bpm_okx(idx_rfbpm_rffe_comm_ok) = true;

bpms = rfbpms(idx_rfbpm_afc_comm_ok); % only RF BPMs with active AFCs

if ~isempty(bpms)
    % Start quick amplitude test
    bpm_ok2_ = bpm_checkamp_quick(bpms, checkamp_param);
    
    idx_amp_ok = find(bpm_ok2_);
    bpm_ok2 = x;
    bpm_ok2(idx_rfbpm_afc_comm_ok(idx_amp_ok)) = true;
    
    % Start BPM Attenuator Test
    logtext(fid, 'trace', 'Checking BPM attenuators or cables or RFFE/AFC correspondence...');
    [bpm_ok3_, bpm_ok4_] = bpm_checkatt(bpms, checkatt_param);
    
    idx_att_ac_ok = find(bpm_ok3_);
    bpm_ok3 = x;
    bpm_ok3(idx_rfbpm_afc_comm_ok(idx_att_ac_ok)) = true;

    idx_att_bd_ok = find(bpm_ok4_);
    bpm_ok4 = x;
    bpm_ok4(idx_rfbpm_afc_comm_ok(idx_att_bd_ok)) = true;

    % Start BPM Reference Clock Test
    logtext(fid, 'trace', 'Checking if BPM clocks are locked to the reference clock sent through the crate backplane...');
    bpm_ok5_ = bpm_islocked(bpms);
    idx_lock_ok = find(bpm_ok5_);
    bpm_ok5 = x;
    bpm_ok5(idx_rfbpm_afc_comm_ok(idx_lock_ok)) = true;
    
    bpms_locked = bpms(bpm_ok5);
    
    if ~isempty(bpms_locked)
        % Start BPM Switching Test
        logtext(fid, 'trace', 'Checking if switching works properly on locked BPMs...');
        
        bpm_ok6_ = bpm_checksw(bpms_locked, checksw_param);
        idx_sw_ok = find(bpm_ok6_);
        bpm_ok6 = x;
        bpm_ok6(idx_rfbpm_afc_comm_ok(idx_lock_ok(idx_sw_ok))) = true;
        
        % Start Monitoring Amplitude test
        logtext(fid, 'trace', 'Starting Amplitude test...');
        [X,Y,pv_names] = bpm_checkamp(bpms_locked, checkamp_param);
        
        raw_results.monit_amp = Y;
        raw_results.t = X*period_ms/1e3;
        raw_results.pv_names = pv_names;
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

results = [bpm_ok1 bpm_ok2 bpm_ok3 bpm_ok4 bpm_ok5 bpm_ok6];
disp_results(results, rfbpms, {'Test #1', 'Test #2', 'Test #3', 'Test #4', 'Test #5', 'Test #6'});
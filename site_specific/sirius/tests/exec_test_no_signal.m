function r = exec_test_no_signal(bpm_config_path, crate_number, log_filename)

if nargin < 3 || isempty(log_filename)
    fid_logfile = [];
else
    fid_logfile = fopen(log_filename, 'a');
end

fid = [1 fid_logfile];

filetext = readstrlines(fullfile(bpm_config_path, 'bpm', sprintf('names_crate%02d.cfg', crate_number)), '%s %s');

allbpms = filetext{1};
bpmtypes = filetext{2};

bpms = allbpms(strcmp(bpmtypes, 'rfbpm-sr') | strcmp(bpmtypes, 'rfbpm-boo'));
pbpms = allbpms(strcmp(bpmtypes, 'pbpm'));

config_files_bpm = { ...
    fullfile(bpm_config_path, 'bpm', 'rfbpms', 'backend_reset.cfg')
    fullfile(bpm_config_path, 'bpm', 'rfbpms', 'backend_basic.cfg')
    fullfile(bpm_config_path, 'bpm', 'rfbpms', 'sr', 'sirius-sr-button_bpm.cfg')
    };

config_files_pbpm = { ...
    fullfile(bpm_config_path, 'bpm', 'pbpms', 'sirius-frontend-pbpm.cfg')
    };

% Apply configuration and check which BPMs are alive
logtext(fid, 'trace', 'Applying BPM basic configurations and checking active units...');
[bpms, bpms_inactive] = bpm_applyconfig(bpms, config_files_bpm);
for i=1:length(bpms)
    logtext(fid, 'info', sprintf('Active BPM: %s', bpms{i}));
end
for i=1:length(bpms_inactive)
    logtext(fid, 'warning', sprintf('Inactive BPM: %s', bpms_inactive{i}));
end

logtext(fid, 'trace', 'Applying photon BPM basic configurations and checking active units...');
[pbpms, pbpms_inactive] = bpm_applyconfig(pbpms, config_files_pbpm);
for i=1:length(pbpms)
    logtext(fid, 'info', sprintf('Active photon BPM: %s', pbpms{i}));
end
for i=1:length(pbpms_inactive)
    logtext(fid, 'warning', sprintf('Inactive photon BPM: %s', pbpms_inactive{i}));
end

pause(5);

% Check lock to reference clock of RF BPMs
if ~isempty(bpms)
    logtext(fid, 'trace', 'Checking if BPM clocks are locked to the reference clock sent through the crate backplane...');
    [bpms_locked, bpms_notlocked, bpms_inactive2] = bpm_islocked(bpms);
    bpms_inactive = [bpms_inactive bpms_inactive2];
    if isempty(bpms_notlocked)
        logtext(fid, 'trace', sprintf('All active BPMs are locked to the reference clock.'));
    else
        logtext(fid, 'warning', sprintf('Some BPMs are not locked to the reference clock...'));
        for i=1:length(bpms_notlocked)
            logtext(fid, 'warning', sprintf('Not locked BPM: %s', bpms_notlocked{i}));
        end
    end
end

% Acquire data at different data rates
wvf_names = { ...
    'GEN_AArrayData', ...
    'GEN_BArrayData', ...
    'GEN_CArrayData', ...
    'GEN_DArrayData', ...
    };

logtext(fid, 'trace', 'Acquiring waveforms at ADC data rate...');
r.testdata.adc = bpm_acquire([pbpms; bpms], wvf_names, 0, 100000, 3, 2);

logtext(fid, 'trace', 'Acquiring waveforms at TBT data rate...');
r.testdata.tbt = bpm_acquire([pbpms; bpms], wvf_names, 2, 100000, 3, 2);

logtext(fid, 'trace', 'Acquiring waveforms at FOFB data rate...');
r.testdata.fofb = bpm_acquire([pbpms; bpms], wvf_names, 3, 100000, 3, 2);

r.status.bpm.active = bpms;
r.status.bpm.inactive = bpms_inactive;
r.status.bpm.locked = bpms_locked;
r.status.bpm.notlocked = bpms_notlocked;
r.status.pbpm.active = pbpms;
r.status.pbpm.inactive = pbpms_inactive;

if ~isempty(fid_logfile)
    fclose(fid_logfile);
end

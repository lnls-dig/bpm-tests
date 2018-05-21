function r = configbpm(config_path, crate_number, log_filename)
%CONFIGBPM   Configure BPMs of a single crate.
%   r = CONFIGBPM(config_path, crate_number, log_filename)

%   Copyright (C) 2017 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author (Jun-2017): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

if nargin < 3 || isempty(log_filename)
    fid_logfile = [];
else
    fid_logfile = fopen(log_filename, 'a');
end

fid = [1 fid_logfile];

colorized = true;

filetext = readstrlines(fullfile(config_path, 'bpm', sprintf('names_crate%02d.cfg', crate_number)), '%s %s');

allbpms = filetext{1};
bpmtypes = filetext{2};

% Filter out inactive BPMs
config_files_allbpms = { ...
    'monit.cfg', ...
    %'triggers.cfg', ...
    };

logtext(fid, 'trace', 'Applying basic configurations and checking active units...');
allbpms = caputbpmconfig(allbpms, config_files_allbpms, fid, colorized);

% Find BPM types
pbpms = allbpms(strcmp(bpmtypes, 'pbpm'));
bpms = allbpms(strcmp(bpmtypes, 'rfbpm-sr') | strcmp(bpmtypes, 'rfbpm-boo') | strcmp(bpmtypes, 'rfbpm-sp'));
bpms_sr = allbpms(strcmp(bpmtypes, 'rfbpm-sr'));
bpms_boo = allbpms(strcmp(bpmtypes, 'rfbpm-boo'));
bpms_sp = allbpms(strcmp(bpmtypes, 'rfbpm-sp'));

config_files_rfbpm = { ...
    %fullfile(config_path, 'bpm', 'rfbpms', 'backend_reset.cfg')
    fullfile(config_path, 'bpm', 'rfbpms', 'backend_basic.cfg')
    };

config_files_rfbpm_rffe = { ...
    fullfile(config_path, 'bpm', 'rfbpms', 'rffe_basic.cfg')
    };

config_files_rfbpm_sr = { ...
    fullfile(config_path, 'bpm', 'rfbpms', 'sr', 'sirius-sr-button_bpm.cfg')
    };

config_files_rfbpm_boo = { ...
    fullfile(config_path, 'bpm', 'rfbpms', 'boo', 'sirius-boo-button_bpm.cfg')
    };

config_files_rfbpm_sp = { ...
    fullfile(config_path, 'bpm', 'rfbpms', 'sp', 'sirius-tl-stripline_bpm.cfg')
    };

config_files_pbpm = { ...
    fullfile(config_path, 'bpm', 'pbpms', 'sirius-frontend-pbpm.cfg')
    };

logtext(fid, 'trace', 'Applying basic BPM configurations and checking active units...');
bpms = caputbpmconfig(bpms, config_files_rfbpm, fid, colorized);

logtext(fid, 'trace', 'Applying RFFE configurations and checking active units...');
bpms = caputbpmconfig(bpms, config_files_rfbpm_rffe, fid, colorized);

logtext(fid, 'trace', 'Applying Storage Ring BPM configurations and checking active units...');
bpms_sr = caputbpmconfig(bpms_sr, config_files_rfbpm_sr, fid, colorized);

logtext(fid, 'trace', 'Applying Booster BPM configurations and checking active units...');
bpms_boo = caputbpmconfig(bpms_boo, config_files_rfbpm_boo, fid, colorized);

logtext(fid, 'trace', 'Applying Single Pass BPM configurations and checking active units...');
bpms_sp = caputbpmconfig(bpms_sp, config_files_rfbpm_sp, fid, colorized);

logtext(fid, 'trace', 'Applying Photon BPM configurations and checking active units...');
pbpms = caputbpmconfig(pbpms, config_files_pbpm, fid, colorized);

r.allbpms = allbpms;
r.bpms = bpms;
r.bpms_sr = bpms_sr;
r.bpms_boo = bpms_boo;
r.bpms_sp = bpms_sp;
r.pbpms = pbpms;

if ~isempty(fid_logfile)
    fclose(fid_logfile);
end

function [active_units, inactive_units] = caputbpmconfig(bpmnames, config_files, file_id, colorized)

[active_units, inactive_units] = bpm_applyconfig(bpmnames, config_files);
for i=1:length(bpmnames)
    logtext(file_id, 'info', sprintf('Active: %s', bpmnames{i}), colorized);
end
for i=1:length(inactive_units)
    logtext(file_id, 'error', sprintf('Inactive: %s', inactive_units{i}), colorized);
end

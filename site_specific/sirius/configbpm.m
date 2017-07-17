function configbpm(bpm_config_path)
%CONFIGBPM   Configure BPMs.
%   CONFIGBPM(bpm_config_path)

%   Copyright (C) 2017 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author (Jun-2017): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

[~, ~, allslotnames] = sirius_bpm_slot_mapping;
allbpms = allslotnames(4,7:23);
pbpms = allbpms(1:4);
rfbpms = allbpms(5:end);
rfbpms_sr = rfbpms(1:10);
rfbpms_boo = rfbpms(11:13);
rfbpms_sp = {};

config_files_allbpms = { ...
    'triggers.cfg', ...
    };

config_files_pbpms = { ...
    'sirius-frontend-xbpm-debug.cfg', ...
    };

config_files_rfbpms = { ...
    'backend_reset.cfg', ...
    'backend_basic.cfg', ...
    'rffe_basic.cfg', ...
    };

config_files_rfbpms_sr = { ...
    'sirius-sr-button_bpm-debug-480mhz.cfg', ...
    };

config_files_rfbpms_boo = { ...
    'sirius-boo-button_bpm-debug-480mhz.cfg', ...
    };

config_files_rfbpms_sp = { ...
    };

caputbpmconfig(allbpms, fullfile(bpm_config_path, 'allbpms'), config_files_allbpms);
caputbpmconfig(pbpms, fullfile(bpm_config_path, 'pbpms'),   config_files_pbpms);
caputbpmconfig(rfbpms_sr, fullfile(bpm_config_path, 'rfbpms'),  config_files_rfbpms);
caputbpmconfig(rfbpms_sr, fullfile(bpm_config_path, 'rfbpms', 'sr'),  config_files_rfbpms_sr);
caputbpmconfig(rfbpms_boo, fullfile(bpm_config_path, 'rfbpms', 'boo'),  config_files_rfbpms_boo);
caputbpmconfig(rfbpms_sp, fullfile(bpm_config_path, 'rfbpms', 'sp'),  config_files_rfbpms_sp);

function caputbpmconfig(bpmnames, config_path, config_files)

for i=1:length(config_files)
    aux = readstrlines(fullfile(config_path, config_files{i}), '%s %f');
    activebpm = caput(buildpvnames(bpmnames, aux{1}(1)), aux{2}(1));
    activebpm = activebpm == 1; % to overcome MCA limitation (return double instead of logical)
    bpmnames = bpmnames(activebpm);
    nbpms = length(bpmnames);
    caput(buildpvnames(bpmnames, aux{1}(2:end)), repmat(aux{2}(2:end),nbpms,1));
end
function [bpm_ok, bpm_set] = bpm_config(config_path, crate_number)
%CONFIGBPM   Configure BPMs of a single crate.
%   [bpm_ok, bpm_set] = BPM_CONFIG(config_path, crate_number)

%   Copyright (C) 2017 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author (Jun-2017): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

filetext = readstrlines(fullfile(config_path, 'bpm', sprintf('names_crate%02d.cfg', crate_number)), '%s %s');
bpms = filetext{1};
bpmtypes = filetext{2};

rfbpms = bpms(strcmp(bpmtypes, 'rfbpm-sr') | strcmp(bpmtypes, 'rfbpm-boo') | strcmp(bpmtypes, 'rfbpm-sp'));

bpm_set = { ...
    bpms; ...                                   All BPMs
    bpms(strcmp(bpmtypes, 'pbpm')); ...         Photon BPMs
    rfbpms; ...                                 RF BPMs (AFC and FMC ADC setting)
    rfbpms; ...                                 RF BPMs (RFFE settings)
    bpms(strcmp(bpmtypes, 'rfbpm-sr')); ...     RF BPMs (only Storage Ring)
    bpms(strcmp(bpmtypes, 'rfbpm-boo')); ...    RF BPMs (only Booster)
    bpms(strcmp(bpmtypes, 'rfbpm-sp')); ...     RF BPMs (only Single Pass (Transfer Lines or Linac))
    };

% Filter out inactive BPMs
probe_config_file = 'monit.cfg';

config_files_set = { ...
    { ...   All BPMs
%     'triggers.cfg'; ...
    fullfile(config_path, 'bpm', 'allbpms', 'monit.cfg'); ...
    };
    
    { ...   Photon BPMs
    fullfile(config_path, 'bpm', 'pbpms', 'sirius-frontend-pbpm.cfg'); ...
    };
    
    { ...   RF BPMs (AFC and FMC ADC setting)
    %fullfile(config_path, 'bpm', 'rfbpms', 'backend_reset.cfg'); ...
    fullfile(config_path, 'bpm', 'rfbpms', 'backend_basic.cfg'); ...
    };
    
    { ...   RF BPMs (RFFE settings)
    fullfile(config_path, 'bpm', 'rfbpms', 'rffe_basic.cfg'); ...
    };
    
    { ...	RF BPMs (only Storage Ring)
    fullfile(config_path, 'bpm', 'rfbpms', 'sr', 'sirius-sr-button_bpm.cfg'); ...
    };
    
    { ...	RF BPMs (only Booster)
    fullfile(config_path, 'bpm', 'rfbpms', 'boo', 'sirius-boo-button_bpm.cfg'); ...
    };
    
    { ...	RF BPMs (only Single Pass (Transfer Lines or Linac))
    fullfile(config_path, 'bpm', 'rfbpms', 'sp', 'sirius-tl-stripline_bpm.cfg'); ...
    };
    };

bpm_ok = cell(length(bpm_set),1);

for i=1:length(bpm_set)
    bpm_ok{i} = bpm_applyconfig(bpm_set{i}, config_files_set{i});
end
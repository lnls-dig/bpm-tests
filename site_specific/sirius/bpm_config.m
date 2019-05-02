function [bpm_ok, bpm_set] = bpm_config(config_path, crate_number)
%CONFIGBPM   Configure BPMs of a single crate.
%   [bpm_ok, bpm_set] = BPM_CONFIG(config_path, crate_number)

%   Copyright (C) 2017 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author (Jun-2017): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

names = bpm_names(config_path, crate_number);

rfbpms = [names.rfbpms.sp; names.rfbpms.boo; names.rfbpms.sr];
bpms = [rfbpms; names.pbpms];

bpm_set = { ...
    names.tim;
    bpms; ...                                   All BPMs
    names.pbpms; ...                            Photon BPMs
    rfbpms; ...                                 RF BPMs (AFC and FMC ADC setting)
    rfbpms; ...                                 RF BPMs (RFFE settings)
    names.rfbpms.sr; ...                        RF BPMs (only Storage Ring)
    names.rfbpms.boo; ...                       RF BPMs (only Booster)
    names.rfbpms.sp; ...                        RF BPMs (only Single Pass (Transfer Lines or Linac))
    {}; ...
    };

% Filter out inactive BPMs
config_files_set = { ...
    { ...   All Timing Boards
    fullfile(config_path, 'bpm', 'timing', 'evr.cfg'); ...
    };

    { ...   All BPMs
    fullfile(config_path, 'bpm', 'allbpms', 'triggers.cfg'); ...
    fullfile(config_path, 'bpm', 'allbpms', 'monit.cfg'); ...
    };
    
    { ...   Photon BPMs
    fullfile(config_path, 'bpm', 'pbpms', 'sirius-frontend-pbpm.cfg'); ...
    };
    
    { ...   RF BPMs (AFC and FMC ADC setting)
    fullfile(config_path, 'bpm', 'rfbpms', 'backend_reset_1.cfg'); ...
    fullfile(config_path, 'bpm', 'rfbpms', 'backend_reset_2.cfg'); ...
    fullfile(config_path, 'bpm', 'rfbpms', 'backend_reset_3.cfg'); ...
    fullfile(config_path, 'bpm', 'rfbpms', 'backend_reset_4.cfg'); ...
    fullfile(config_path, 'bpm', 'rfbpms', 'backend_basic.cfg'); ...
    };
    
    { ...   RF BPMs (RFFE settings)
    fullfile(config_path, 'bpm', 'rfbpms', 'rffe_basic.cfg'); ...
    };
    
    { ...   RF BPMs (only Storage Ring)
    fullfile(config_path, 'bpm', 'rfbpms', 'sr', 'sirius-sr-button_bpm.cfg'); ...
    };
    
    { ...   RF BPMs (only Booster)
    fullfile(config_path, 'bpm', 'rfbpms', 'boo', 'sirius-boo-button_bpm.cfg'); ...
    };
    
    { ...   RF BPMs (only Single Pass (Transfer Lines or Linac))
    fullfile(config_path, 'bpm', 'rfbpms', 'sp', 'sirius-tl-stripline_bpm.cfg'); ...
    };
    
    { ...   PV by PV
    fullfile(config_path, 'bpm', 'pvs', 'ksum.cfg'); ...
    fullfile(config_path, 'bpm', 'pvs', 'triggerdelay.cfg'); ...
    };
    };

bpm_ok = cell(length(bpm_set),1);

for i=1:length(bpm_set)
    bpm_ok{i} = bpm_applyconfig(bpm_set{i}, config_files_set{i});
end

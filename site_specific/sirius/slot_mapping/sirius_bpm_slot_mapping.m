function [areas, devices, pvnames, bpm_type_by_crate] = sirius_bpm_slot_mapping

nsectors = 20;
ncrates = 22;
nbpmslots = 24;

% Straight sections names
ss_names_by_sector = { ...
    'SA'; ... % sector 01
    'SB'; ... % sector 02
    'SP'; ... % sector 03
    'SB'; ... % sector 04
    'SA'; ... % sector 05
    'SB'; ... % sector 06
    'SP'; ... % sector 07
    'SB'; ... % sector 08
    'SA'; ... % sector 09
    'SB'; ... % sector 10
    'SP'; ... % sector 11
    'SB'; ... % sector 12
    'SA'; ... % sector 13
    'SB'; ... % sector 14
    'SP'; ... % sector 15
    'SB'; ... % sector 16
    'SA'; ... % sector 17
    'SB'; ... % sector 18
    'SP'; ... % sector 19
    'SB'; ... % sector 20
    };

sr_bpm_names_by_sector = cell(nsectors,1);
booster_bpm_names_by_sector = cell(nsectors,1);

booster_seq_number = 1;
for sector_number = 1:nsectors
    % Storage ring BPMs names per sector
    sr_bpm_names =  { ...
        'SI', sprintf('%0.2d%sFE', sector_number, ss_names_by_sector{sector_number}), 'DI-PBPM', '-1'; ...
        'SI', sprintf('%0.2d%sFE', sector_number, ss_names_by_sector{sector_number}), 'DI-PBPM', '-2'; ...
        'SI', sprintf('%0.2dBCFE', sector_number), 'DI-PBPM', '-1'; ...
        'SI', sprintf('%0.2dBCFE', sector_number), 'DI-PBPM', '-2'; ...
        'SI', sprintf('%0.2d%s',   sector_number, ss_names_by_sector{sector_number}), 'DI-BPM', '-1'; ...
        'SI', sprintf('%0.2d%s',   sector_number, ss_names_by_sector{sector_number}), 'DI-BPM', '-2'; ...
        'SI', sprintf('%0.2dM1',   sector_number), 'DI-BPM', ''; ...
        'SI', sprintf('%0.2dM2',   sector_number), 'DI-BPM', ''; ...
        'SI', sprintf('%0.2dC1',   sector_number), 'DI-BPM', '-1'; ...
        'SI', sprintf('%0.2dC1',   sector_number), 'DI-BPM', '-2'; ...
        'SI', sprintf('%0.2dC2',   sector_number), 'DI-BPM', ''; ...
        'SI', sprintf('%0.2dC3',   sector_number), 'DI-BPM', '-1'; ...
        'SI', sprintf('%0.2dC3',   sector_number), 'DI-BPM', '-2'; ...
        'SI', sprintf('%0.2dC4',   sector_number), 'DI-BPM', '';
        };
    
    % Booster BPMs names per sector
    booster_bpm_names = cell(3,4);
    
    if rem(sector_number,2) == 0
        n = 3;
        bpm_type = { ...
            'none'; ...
            'none'; ...
            'none'; ...
            'none'; ...
            'none'; ...
            'none'; ...
            'pbpm'; ...
            'pbpm'; ...
            'pbpm'; ...
            'pbpm'; ...
            'rfbpm-sr'; ...
            'rfbpm-sr'; ...
            'rfbpm-sr'; ...
            'rfbpm-sr'; ...
            'rfbpm-sr'; ...
            'rfbpm-sr'; ...
            'rfbpm-sr'; ...
            'rfbpm-sr'; ...
            'rfbpm-sr'; ...
            'rfbpm-sr'; ...
            'rfbpm-boo'; ...
            'rfbpm-boo'; ...
            'rfbpm-boo'; ...
            'none'; ...
            };
    else
        n = 2;
        bpm_type = { ...
            'none'; ...
            'none'; ...
            'none'; ...
            'none'; ...
            'none'; ...
            'none'; ...
            'pbpm'; ...
            'pbpm'; ...
            'pbpm'; ...
            'pbpm'; ...
            'rfbpm-sr'; ...
            'rfbpm-sr'; ...
            'rfbpm-sr'; ...
            'rfbpm-sr'; ...
            'rfbpm-sr'; ...
            'rfbpm-sr'; ...
            'rfbpm-sr'; ...
            'rfbpm-sr'; ...
            'rfbpm-sr'; ...
            'rfbpm-sr'; ...
            'rfbpm-boo'; ...
            'rfbpm-boo'; ...
            'none'; ...
            'none'; ...
            };
    end
    
    for j = 1:n
        booster_bpm_names(j,:) = {'BO', sprintf('%0.2dU', booster_seq_number), 'DI-BPM', ''};
        booster_seq_number = booster_seq_number+1;
    end
    
    sr_bpm_names_by_sector{sector_number} = sr_bpm_names;
    booster_bpm_names_by_sector{sector_number} = booster_bpm_names;
    bpm_type_by_crate(sector_number, :) = bpm_type;
end

linac_tl_bpm_names =  { ...
    'TB', '01', 'DI-BPM', '-1'; ...
    'TB', '01', 'DI-BPM', '-2'; ...
    'TB', '02', 'DI-BPM', '-1'; ...
    'TB', '02', 'DI-BPM', '-2'; ...
    'TB', '03', 'DI-BPM', ''; ...
    'TB', '04', 'DI-BPM', ''; ...
    'TS', '01', 'DI-BPM', ''; ...
    'TS', '02', 'DI-BPM', ''; ...
    'TS', '03', 'DI-BPM', ''; ...
    'TS', '04', 'DI-BPM', '-1'; ...
    'TS', '04', 'DI-BPM', '-2'; ...
    'LI', '01', 'DI-BPM', '-1'; ...
    'LI', '01', 'DI-BPM', '-2'; ...
    'LI', '01', 'DI-BPM', '-3'; ...
    };

bpm_type = { ...
    'none'; ...
    'none'; ...
    'none'; ...
    'none'; ...
    'none'; ...
    'none'; ...
    'none'; ...
    'none'; ...
    'none'; ...
    'none'; ...
    'rfbpm-sp'; ...
    'rfbpm-sp'; ...
    'rfbpm-sp'; ...
    'rfbpm-sp'; ...
    'rfbpm-sp'; ...
    'rfbpm-sp'; ...
    'rfbpm-sp'; ...
    'rfbpm-sp'; ...
    'rfbpm-sp'; ...
    'rfbpm-sp'; ...
    'rfbpm-sp'; ...
    'rfbpm-sp'; ...
    'rfbpm-sp'; ...
    'rfbpm-sp'; ...
    };

% Build all crates's slot occupancy descriptions as cell arrays
bpmslots_occupancy_by_crate = cell(ncrates, 1);
crate_number = 1;

% Crates from 1 to 20 (Storage Ring and Booster BPMs)
for sector_number = 1:nsectors
    bpmslots_occupancy = cell(nbpmslots, 4);
    bpmslots_occupancy(7:23,:) = [sr_bpm_names_by_sector{sector_number}; booster_bpm_names_by_sector{sector_number}];
    
    bpmslots_occupancy_by_crate{crate_number} = bpmslots_occupancy;
    
    crate_number = crate_number+1;
end

% Crate number 21 (LINAC and Trasnfer Lines BPMs)
bpmslots_occupancy_by_crate{crate_number}(11:24,:) = linac_tl_bpm_names;
bpm_type_by_crate(crate_number, :) = bpm_type;
crate_number = crate_number+1;

% Crate number 22 (Spares)
bpmslots_occupancy_by_crate{crate_number} = cell(nbpmslots, 4);

% Fill names of unused slots
for crate_number = 1:ncrates
    for bpmslot_number=1:nbpmslots
        if isempty(bpmslots_occupancy_by_crate{crate_number}{bpmslot_number})
            bpmslots_occupancy_by_crate{crate_number}(bpmslot_number,:) =  {'XX', sprintf('%0.2dSL%0.2d', crate_number, bpmslot_number), 'DI-BPM', '';};
        end
    end
end

for crate_number = 1:ncrates
    for bpmslot_number=1:nbpmslots
        areas{crate_number, bpmslot_number} = sprintf('%s-%s', bpmslots_occupancy_by_crate{crate_number}{bpmslot_number,1}, bpmslots_occupancy_by_crate{crate_number}{bpmslot_number,2});
        devices{crate_number, bpmslot_number} = sprintf('%s%s', bpmslots_occupancy_by_crate{crate_number}{bpmslot_number,3}, bpmslots_occupancy_by_crate{crate_number}{bpmslot_number,4});
        pvnames{crate_number, bpmslot_number} = [areas{crate_number, bpmslot_number} ':' devices{crate_number, bpmslot_number}];
    end
end
[~,~,all_bpm_names] = sirius_bpm_slot_mapping;
fmcpico_pvs = all_bpm_names(4,7:10);

ranges = [0 1];
acqchs = [0 2 3];

npts = 100000;

sn_fmcpico = { ...
    '17044'; ...
    '17033'; ...
    '17048'; ...
    '17041'; ...
    };

sn_afc = { ...
    '1100030019'; ...
    '1100030019'; ...
    '1100030014'; ...
    '1100030014'; ...
    };

slot_name = {...
    'AMC04_FMC1'; ...
    'AMC04_FMC2'; ...
    'AMC05_FMC1'; ...
    'AMC05_FMC2'; ...
    };


for i=1:length(sn_fmcpico)
    dirname = ['sn' sn_fmcpico{i}];
    if ~exist(dirname, 'dir')
        mkdir(dirname);
    end
end

caput(buildpvnames(fmcpico_pvs, 'ACQTriggerRep'), 0);
caput(buildpvnames(fmcpico_pvs, 'ACQSamplesPre'), npts);

for i=1:length(fmcpico_pvs)
    hacq{i} = mcaopen(buildpvnames(fmcpico_pvs{i}, 'ACQChannel'));
    hwvf{i} = caopenwvf(buildpvnames(fmcpico_pvs{i}, {'GEN_AArrayData', 'GEN_BArrayData', 'GEN_CArrayData', 'GEN_DArrayData'}));
    hrng{i} = mcaopen(buildpvnames(fmcpico_pvs{i}, {'FMCPICORngR0', 'FMCPICORngR1', 'FMCPICORngR2', 'FMCPICORngR3'}));
    htrig{i} = mcaopen(buildpvnames(fmcpico_pvs{i}, 'ACQTriggerEvent'));
end

for i=1 %1:length(fmcpico_pvs)
    %input(sprintf('Connect cables to board #%d (S/N %s) and press ENTER.', i, sn_fmcpico{i}));

    data = zeros(npts, 4, length(ranges), length(acqchs));

    for j=1:length(ranges)
        caputh(hrng{i}, ranges(j));
        fprintf('  > RANGE %d\n', ranges(j));

        for k=1:length(acqchs)
            fprintf('  >> Acq. channel %d\n', acqchs(k));
            caputh(hacq{i}, acqchs(k));
            pause(2);
            caputh(htrig{i}, 0);
            pause(2);
            data(:,:,j,k) = cagetwvfh(hwvf{i});
        end
        fprintf('\n');
    end

    save(fullfile(['sn' sn_fmcpico{i}], sprintf('sn%s_afc%s_slot%s_%s', sn_fmcpico{i}, sn_afc{i}, slot_name{i}, datestr(now,30))), 'data');
    fprintf('Waveforms saved.\n\n');
end

for i=1:length(hwvf)
    mcaclose(hacq{i});
    mcaclose(hrng{i});
    mcaclose(htrig{i});
    caclosewvf(hwvf{i});
end

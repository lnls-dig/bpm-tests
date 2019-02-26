%%
archiver_addres = 'http://10.0.6.57:11998';
[~, ~, allslotnames] = sirius_bpm_slot_mapping;

bpms{1} = allslotnames(1,13:22)';
bpms{2} = allslotnames(2,13:23)';
bpms{3} = allslotnames(3,13:22)';
bpms{4} = allslotnames(4,13:23)';
bpms{5} = allslotnames(5,13:22)';
bpms{6} = allslotnames(6,11:23)';
bpms{7} = allslotnames(7,11:22)';
bpms{8} = allslotnames(8,11:23)';
bpms{9} = allslotnames(9,11:22)';
bpms{10} = allslotnames(10,13:23)';
bpms{11} = allslotnames(11,11:22)';
bpms{12} = allslotnames(12,11:23)';
bpms{13} = allslotnames(13,13:22)';
bpms{14} = allslotnames(14,11:23)';
bpms{15} = allslotnames(15,11:22)';
bpms{16} = allslotnames(16,13:23)';
bpms{17} = allslotnames(17,13:22)';
bpms{18} = allslotnames(18,13:23)';
bpms{19} = allslotnames(19,13:22)';
bpms{20} = allslotnames(20,13:23)';
bpms{21} = allslotnames(21,11:21)';
bpms{22} = allslotnames(22,11:22)'; % FIXME


% remove_bpms = { ...
%     'SI-01C1:DI-BPM-2'; ...
%     'SI-01C2:DI-BPM'; ...
%     'SI-03C1:DI-BPM-1'; ...
%     'SI-03C1:DI-BPM-2'; ...
% %     'SI-03C3:DI-BPM-2'; ...
% %     'SI-04C1:DI-BPM-2'; ...
%     'SI-04C4:DI-BPM'; ...
%     'SI-05C1:DI-BPM-2'; ...
%     'SI-06SB:DI-BPM-1'; ...
%     'SI-06SB:DI-BPM-2'; ...
%     'SI-06M1:DI-BPM'; ...
%     'SI-06M2:DI-BPM'; ...
%     'SI-06C1:DI-BPM-1'; ...
%     'SI-06C1:DI-BPM-2'; ...
%     'SI-06C2:DI-BPM'; ...
%     'SI-06C3:DI-BPM-1'; ...
%     'SI-07SP:DI-BPM-1'; ...
%     'SI-07SP:DI-BPM-2'; ...
%     'SI-07C1:DI-BPM-1'; ...
%     'SI-07C2:DI-BPM'; ...
%     'SI-08SB:DI-BPM-1'; ...
%     'SI-08SB:DI-BPM-2'; ...
%     'SI-08M2:DI-BPM'; ...
%     'SI-08C1:DI-BPM-1'; ...
%     'SI-08C1:DI-BPM-2'; ...
%     'SI-08C2:DI-BPM'; ...
%     'SI-08C3:DI-BPM-1'; ...
%     'SI-10M2:DI-BPM'; ...
%     'SI-10C1:DI-BPM-2'; ...
%     };

%%
bpms{31} = { ...
%     'SI-07SP:DI-BPM-1'; ...
%     'SI-07SP:DI-BPM-2'; ...
%     'SI-07C1:DI-BPM-1'; ...
%     'SI-07C2:DI-BPM'; ...
    'SI-10M2:DI-BPM'; ...
    'SI-10C1:DI-BPM-2'; ...
    };

bpms{32} = { ...
    'SI-08SB:DI-BPM-1'; ...
    'SI-08SB:DI-BPM-2'; ...
    'SI-08M1:DI-BPM'; ...
    'SI-08M2:DI-BPM'; ...
    'SI-08C1:DI-BPM-1'; ...
    'SI-08C1:DI-BPM-2'; ...
    'SI-08C2:DI-BPM'; ...
    'SI-08C3:DI-BPM-1'; ...
    %    'SI-08C3:DI-BPM-2'; ...
    %    'SI-08C4:DI-BPM'; ...
    %    'BO-20U:DI-BPM'; ...
    };

bpms{33} = { ...
    'SI-06SB:DI-BPM-1'; ...
    'SI-06SB:DI-BPM-2'; ...
    'SI-06M1:DI-BPM'; ...
    'SI-06M2:DI-BPM'; ...
    'SI-06C1:DI-BPM-1'; ...
    'SI-06C1:DI-BPM-2'; ...
    'SI-06C2:DI-BPM'; ...
    'SI-06C3:DI-BPM-1'; ...
    %   'SI-06C3:DI-BPM-2'; ...
    %   'SI-06C4:DI-BPM'; ...
    %   'BO-15U:DI-BPM'; ...
    };

bpms{34} = { ...
    'SI-01M1:DI-BPM'; ...
    'SI-01M2:DI-BPM'; ...
    'SI-01C1:DI-BPM-1'; ...
    'SI-01C1:DI-BPM-2'; ...
    'SI-01C2:DI-BPM'; ...
    'SI-01C3:DI-BPM-1'; ...
    };

bpms{35} = { ...
    'SI-05C1:DI-BPM-1'; ...
    'SI-05C1:DI-BPM-2'; ...
    'SI-05C2:DI-BPM'; ...
    'SI-05C3:DI-BPM-1'; ...
    };

bpms{36} = { ...
    'SI-03M1:DI-BPM'; ...
    'SI-03M2:DI-BPM'; ...
    'SI-03C1:DI-BPM-1'; ...
    'SI-03C1:DI-BPM-2'; ...
    'SI-03C2:DI-BPM'; ...
    'SI-03C3:DI-BPM-1'; ...
    };

bpms{37} = { ...
    'SI-04M1:DI-BPM'; ...
    'SI-04M2:DI-BPM'; ...
    'SI-04C1:DI-BPM-1'; ...
    %    'SI-04C1:DI-BPM-2'; ...
    'SI-04C2:DI-BPM'; ...
    %    'SI-04C3:DI-BPM-1'; ...
    };

bpms{38} = { ...
    'SI-07SP:DI-BPM-1'; ...
    'SI-07SP:DI-BPM-2'; ...
    'SI-07M1:DI-BPM'; ...
    'SI-07M2:DI-BPM'; ...
    'SI-07C1:DI-BPM-1'; ...
    'SI-07C1:DI-BPM-2'; ...
    'SI-07C2:DI-BPM'; ...
    'SI-07C3:DI-BPM-1'; ...
    };

replaced = {'TS-04:DI-BPM-2'; ...
    'SI-03C3:DI-BPM-2'; ...
    'SI-04C1:DI-BPM-2'; ...
    };

remove_bpms = [bpms{31}; bpms{32}; bpms{33}; bpms{34}; bpms{35}; bpms{36}; bpms{37}; bpms{38}];%; replaced];




for i=1:22
    idx_to_remove = [];
    for j=1:length(bpms{i})
        if any(ismember(bpms{i}{j}, remove_bpms))
            idx_to_remove = [idx_to_remove j];
        end
    end
    if ~isempty(bpms{i})
        bpms{i}(idx_to_remove) = [];
    end
end

exp = { ...
    1, '2018-08-31 22:00:00', 8;
    2, '2018-08-22 22:00:00', 8;
    3, '2018-08-26 22:00:00', 8;
    4, '2018-08-28 23:30:00', 8;
    5, '2018-08-29 22:00:00', 8;
    6, '2018-09-01 16:00:00', 8;
    7, '2018-09-02 22:00:00', 8;
    8, '2018-09-04 22:00:00', 8;
    9, '2018-09-25 22:00:00', 8;
    10, '2018-09-22 22:00:00', 8;
    11, '2018-09-26 20:32:00', 8;
    12, '2018-10-06 22:00:00', 8;
    13, '2018-10-03 22:00:00', 8;
    14, '2018-10-04 23:00:00', 8;
    15, '2018-10-05 22:00:00', 8;
    16, '2018-10-02 23:30:00', 8;
    17, '2018-11-04 21:00:00', 8;
    18, '2018-11-01 22:00:00', 8;
    19, '2018-11-03 22:00:00', 8;
    20, '2018-11-02 22:00:00', 8;
    21, '2018-10-31 23:30:00', 7.5;
    22, '2018-10-30 22:00:00', 8;
    31, '2018-09-27 23:50:00', 8;
    32, '2018-09-30 20:00:00', 8;
    33, '2018-10-10 20:00:00', 8;
    34, '2018-10-11 22:00:00', 8;
    35, '2018-10-12 22:00:00', 8;
    36, '2018-10-13 22:00:00', 8; %38
    37, '2018-10-15 22:00:00', 8;
    38, '2018-10-16 22:00:00', 8;
    };

% % Old periods
%      8, '2018-09-28 14:59:00', 8;
%
%      1, '2018-08-31 20:45:00', 12;
%      2, '2018-08-22 18:00:00', 14+50/60;
%      3, '2018-08-26 20:10:00', 12-25/60;
%      4, '2018-08-28 23:10:00', 12;
%      5, '2018-08-29 21:47:00', 12;
%      6, '2018-09-01 14:40:00', 12;

%%
pvs = {};
data = {};
time = {};
data_std = {};
time_std = {};
for i=1:size(exp,1)
    pvs{i} = buildpvnames(bpms{exp{i,1}}, {'PosX-Mon','PosY-Mon'});
    [data{i}, time{i}] = earetrieve(archiver_addres, pvs{i}, exp{i,2}, exp{i,3}, -3, 'mean_60');
    %[data{i}, time{i}] = earetrieve(archiver_addres, pvs{i}, exp{i,2}, exp{i,3}, -3);
    [data_std{i}, time_std{i}] = earetrieve(archiver_addres, pvs{i}, exp{i,2}, 0.5, -3);
end

%%
for j = 1:length(data)
    clear data_;
    datax = data{j};
    for i=1:length(datax)
        data_{i} = (datax{i}-mean(datax{i}(end)))+(round(length(datax)/2)-i+1)*50;
    end;
    eaplot(pvs{j}, data_, time{j}, -3);
end

%%
pvs_bundle = {};
data_bundle = {};
data_std_bundle = {};
time_bundle = {};
time_std_bundle = {};
interv_bundle = {};
bpms_bundle = {};

x = 0;
for i=1:length(data)
    bpms_bundle = [bpms_bundle; bpms{i}];
    pvs_bundle = [pvs_bundle pvs{i}];
    data_bundle = [data_bundle; data{i}];
    data_std_bundle = [data_std_bundle; data_std{i}];
    time_bundle = [time_bundle; time{i}];
    time_std_bundle = [time_std_bundle; time_std{i}];
    
    interv_bundle{i} = x + (1:length(pvs{i}));
    x = interv_bundle{i}(end);
end

%%
% clear drift;
% for i=1:2:length(data_bundle)
%     drift((i-1)/2 + 1) = max(max(data_bundle{i}) - min(data_bundle{i}), max(data_bundle{i+1}) - min(data_bundle{i+1}));
% end
clear drift;
clear stdvl;
for i=1:length(data_bundle)
    drift(i) = max(data_bundle{i}) - min(data_bundle{i});
    stdvl(i) = max(data_std_bundle{i}) - min(data_std_bundle{i});
end

th_good_not_good = 200;
good = find(drift <= th_good_not_good);
notgood = find(drift > th_good_not_good);

%bpms_good = bpms_bundle(good);
pvs_good = pvs_bundle(good);
data_good = data_bundle(good);
time_good = time_bundle(good);
drift_good = drift(good);

%bpms_notgood = bpms_bundle(notgood);
pvs_notgood = pvs_bundle(notgood);
data_notgood = data_bundle(notgood);
time_notgood = time_bundle(notgood);
drift_notgood = drift(notgood);

[drift_good_sorted, idx_sorting] = sort(drift);

nselected = 21;

clear pvs_good_;
clear data_good_;
clear time_good_;
clear pvs_notgood_;
clear data_notgood_;
clear time_notgood_;
%idx = idx_sorting([1:5 26:34 end-8:end-3]);
idx = idx_sorting(1:nselected);
j=1;
for i=1:length(idx)
    pvs_good_{j} = pvs_bundle{idx(i)};
    data_good_{j} = (data_bundle{idx(i)}-mean(data_bundle{idx(i)}(end)))+(floor(length(idx)/2)-i+1)*50;
    time_good_{j} = time_bundle{idx(i)} - time_bundle{idx(i)}(1);
    j=j+1;
end

idx = idx_sorting(end:-1:end-nselected+1);
j=1;
for i=1:length(idx)
    pvs_notgood_{j} = pvs_bundle{idx(i)};
    data_notgood_{j} = (data_bundle{idx(i)}-mean(data_bundle{idx(i)}(end)))+(floor(length(idx)/2)-i+1)*50;
    time_notgood_{j} = time_bundle{idx(i)} - time_bundle{idx(i)}(1);
    j=j+1;
end

%% Plots
close all



% Figure 1
eaplot(pvs_good_, data_good_, time_good_, 0, 0.5)
xlabel('Time [hour]')
title('')
ylabel('Position [nm]')
set(gca, 'YTick',-20000:50:20000)

% Figure 2
eaplot(pvs_notgood_, data_notgood_, time_notgood_, 0, 0.5)
xlabel('Time [hour]')
title('')
ylabel('Position [nm]')
set(gca, 'YTick',-20000:200:20000)

% Figure 3
figure;
ax_handles(1) = subplot(211);
hist(drift_good,5:10:195)
title('(a)')
xlabel('Position [nm]');
ylabel({'Number of BPM','readings (X or Y)'});
grid on;

ax1 = axis;

ax_handles(2) = subplot(212);
hist(drift_notgood,250:100:2950)
title('(b)')
xlabel('Position [nm]');
ylabel({'Number of BPM','readings (X or Y)'});
grid on;
ax2 = axis;
ax2(1) = 200;
ax2(4) = ax1(4);
axis(ax2);
linkaxes(ax_handles, 'y');
%
% set(ax_handles(1), 'XTick', 0:10:200, 'Position', [0.09 0.5838 0.87 0.35]);
% set(ax_handles(2), 'XTick', 200:200:20000, 'Position', [0.09 0.11 0.87 0.35]);

set(ax_handles(1), 'XTick', 0:10:200, 'Position', [0.09 0.5838 0.87 0.35]);
set(ax_handles(2), 'XTick', 200:200:20000, 'Position', [0.09 0.11 0.87 0.35]);


set(gcf, 'Position',  [365 318 921 574]);

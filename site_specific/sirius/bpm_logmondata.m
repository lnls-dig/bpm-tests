% Parameters
filename = sprintf('matlab_%s.mat', datestr(now, 'yyyymmddHHMMSS')); % Filename
pvs = {'BO-01U:DI-BPM:GEN_AArrayData'}; % PV names
twait = 5;                              % Data taken time [s]
tpoll = 0.01;                           % CA monitor polling period [s]
fevnt = 2;                              % Estimated event rate [Hz]

% Check which PVs are waveforms
npts = caget(buildpvnames(pvs,'NORD', '.'));
npts(isnan(npts)) = 1;

% Install CA monitors
npvs = length(pvs);
nevntsest = fevnt*twait;
iter = zeros(npvs,1);
h = zeros(npvs,1);
for i=1:npvs
    data_temp{i} = [];
    data{i} = nan(npts(i), nevntsest);
    tstamp{i} = nan(7, nevntsest);
    h(i) = mcaopen(pvs{i});
    mcamon(h(i), sprintf('bpm_logmondata_callback(%d)', i));
end

% Poll CA monitors
for i=1:ceil(twait/tpoll)
    mca(600);
    pause(tpoll)
end

% Provide some time for ending the execution of monitor callbacks
pause(1);

% Clean CA monitors
hcleanup = mcamon;
for i=1:length(hcleanup)
    mcaclearmon(hcleanup(i));
end

save(filename, 'data', 'tstamp', 'pvs', '-v7')
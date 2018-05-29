function [bpm_ok, raw, info] = bpm_checksw(bpms, params, active)

nbpms = length(bpms);

if nargin < 3 || isempty(active)
    active = true(nbpms, 1);
end

bpms_active = bpms(active);

sw_sts = caget(buildpvnames(bpms_active, 'SwMode-Sts'));

% Turn switching off
caput(buildpvnames(bpms_active, 'SwMode-Sel'), 1);
pause(0.5);

% Retrieve BPMs' numerology and determine number of points for coherent sampling
h = caget(buildpvnames(bpms_active, 'INFOHarmonicNumber-RB'));
nadc = caget(buildpvnames(bpms_active, 'INFOTBTRate-RB'));
nsw = 2*caget(buildpvnames(bpms_active, 'SwDivClk-RB'));

sw_adc_factor = round(nsw./nadc);

nyqzone = floor(h./nadc*2);
nyqzone_even = mod(nyqzone,2);
nif = nyqzone_even.*(nadc/2 - h + nyqzone.*nadc/2) + (1-nyqzone_even).*(h - nyqzone.*nadc/2);

nperiods = floor(1e5./nsw);
npts = nperiods.*nsw;

idx_swharm_p1 = (nif.*sw_adc_factor+1).*nperiods+1;
idx_swharm_m1 = (nif.*sw_adc_factor-1).*nperiods+1;

% Preapre for data acquistion
wvf_names = {'GEN_AArrayData', 'GEN_CArrayData', 'GEN_BArrayData', 'GEN_DArrayData'};

% Run data aqcuisitions with switching off
data_nosw = adc_acquire(bpms, active, wvf_names, npts);

% Turn switching on
caput(buildpvnames(bpms_active, 'SwMode-Sel'), 3);
pause(2);

% Run data aqcuisitions with switching on
data_sw = adc_acquire(bpms, active, wvf_names, npts);

% Compare FFTs
bpm_ok = nan(length(bpms),1);
j = 1;
for i=1:length(bpms)
    if active(i)
        if ~isempty(data_nosw{i}) && ~isempty(data_sw{i})
            window = repmat(flattopwin(npts(j)), 1, size(data_nosw{i},2));
            fft_wvfs_nosw = abs(fft(data_nosw{i}.*window));
            fft_wvfs_sw = abs(fft(data_sw{i}.*window));
            bpm_ok(i) = double(all((fft_wvfs_nosw(idx_swharm_p1(j), :)./fft_wvfs_sw(idx_swharm_p1(j), :) < params.swharm_threshold) & (fft_wvfs_nosw(idx_swharm_m1(j), :)./fft_wvfs_sw(idx_swharm_m1(j), :) < params.swharm_threshold)));
        end
        j=j+1;

    end
end

caput(buildpvnames(bpms_active, 'SwMode-Sel'), sw_sts);

info.test_name = 'Switching';
info.version = '1.0.1';

raw.bpm = bpms;
raw.params = params;
raw.active = active;
raw.data_nosw = data_nosw;
raw.data_sw = data_sw;
raw.h = h;
raw.nadc = nadc;
raw.nsw = nsw;


function data = adc_acquire(bpms, active, wvf_names, npts)

j = 1;
for i=1:length(bpms)
    if active(i)
        data_ = bpm_acquire(bpms(i), wvf_names, 0, npts(j), 1, 0.5);
        data{i} = data_.wvfs;
        j=j+1;
    else
        data{i} = [];
    end
end
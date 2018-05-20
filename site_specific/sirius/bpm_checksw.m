function [bpms_switching, bpms_notswitching, bpms_inactive] = bpm_checksw(bpm_names, threshold)

h = caget(buildpvnames(bpm_names, 'INFOHarmonicNumber-RB'));
nadc = caget(buildpvnames(bpm_names, 'INFOTBTRate-RB'));
nsw = 2*caget(buildpvnames(bpm_names, 'SwDivClk-RB'));

sw_adc_factor = round(nsw/nadc);

nyqzone = floor(h./nadc*2);
if mod(nyqzone,2) == 1
    nif = (nadc/2 - h + nyqzone.*nadc/2);
else
    nif = h - nyqzone.*nadc/2;
end

nperiods = floor(1e5/nsw);

npts = nperiods*nsw;

idx_carrier = nif*sw_adc_factor*nperiods+1;
idx_swharm = (nif*sw_adc_factor+1)*nperiods+1;

wvf_names = {'AmplA-Mon', 'AmplC-Mon', 'AmplB-Mon', 'AmplD-Mon'};

r = bpm_acquire(bpm_names, wvf_names, 0, npts);

fft_wvfs = abs(fft(r.wvfs));

switching = fft_wvfs(:, idx_swharm)./fft_wvfs(:, idx_carrier) > threshold;

nwvfs = size(r.wvfs,2);

switching = all(reshape(switching, 4, nwvfs/4));

bpms_switching = bpm_names(switching);
bpms_notswitching = bpm_names(~switching);
bpms_inactive = []; % TODO: return inactive BPMs

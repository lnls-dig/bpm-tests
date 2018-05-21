function [bpms_switching, bpms_notswitching, bpms_inactive] = bpm_checksw(bpm_names, threshold)

h = caget(buildpvnames(bpm_names, 'INFOHarmonicNumber-RB'));
nadc = caget(buildpvnames(bpm_names, 'INFOTBTRate-RB'));
nsw = 2*caget(buildpvnames(bpm_names, 'SwDivClk-RB'));

sw_adc_factor = round(nsw./nadc);

nyqzone = floor(h./nadc*2);
nyqzone_even = mod(nyqzone,2);
nif = nyqzone_even.*(nadc/2 - h + nyqzone.*nadc/2) + (1-nyqzone_even).*(h - nyqzone.*nadc/2);

nperiods = floor(1e5./nsw);

npts = nperiods.*nsw;

idx_carrier = nif.*sw_adc_factor.*nperiods+1;
idx_swharm_p1 = (nif.*sw_adc_factor+1).*nperiods+1;
idx_swharm_m1 = (nif.*sw_adc_factor-1).*nperiods+1;
    
wvf_names = {'GEN_AArrayData', 'GEN_CArrayData', 'GEN_BArrayData', 'GEN_DArrayData'};

for i=1:length(bpm_names)
    r = bpm_acquire(bpm_names(i), wvf_names, 0, npts(i));
    fft_wvfs = abs(fft(r.wvfs));
    switching(i) = all((fft_wvfs(idx_swharm_p1(i), :)./fft_wvfs(idx_carrier(i), :) > threshold) & (fft_wvfs(idx_swharm_m1(i), :)./fft_wvfs(idx_carrier(i), :) > threshold));
end

bpms_switching = bpm_names(switching);
bpms_notswitching = bpm_names(~switching);
bpms_inactive = []; % TODO: return inactive BPMs

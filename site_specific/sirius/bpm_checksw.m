function [bpms_switching, bpms_notswitching, bpms_inactive] = bpm_checksw(bpms, params)

sw_sts = caget(buildpvnames(bpms, 'SwMode-Sts'));
caput(buildpvnames(bpms, 'SwMode-Sel'), 3);

h = caget(buildpvnames(bpms, 'INFOHarmonicNumber-RB'));
nadc = caget(buildpvnames(bpms, 'INFOTBTRate-RB'));
nsw = 2*caget(buildpvnames(bpms, 'SwDivClk-RB'));

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

switching = false(1,length(bpms));
for i=1:length(bpms)
    r = bpm_acquire(bpms(i), wvf_names, 0, npts(i));
    fft_wvfs = abs(fft(r.wvfs));
    switching(i) = all((fft_wvfs(idx_swharm_p1(i), :)./fft_wvfs(idx_carrier(i), :) > params.swharm_threshold) & (fft_wvfs(idx_swharm_m1(i), :)./fft_wvfs(idx_carrier(i), :) > params.swharm_threshold));
end

caput(buildpvnames(bpms, 'SwMode-Sel'), sw_sts);

bpms_switching = bpms(switching);
bpms_notswitching = bpms(~switching);
bpms_inactive = []; % TODO: return inactive BPMs

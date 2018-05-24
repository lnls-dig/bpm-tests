function bpm_ok = bpm_checksw(bpms, params, active)

if nargin < 3 || isempty(active)
    active = true(size(bpms));
end

bpms_active = bpms(active);

sw_sts = caget(buildpvnames(bpms_active, 'SwMode-Sts'));
caput(buildpvnames(bpms_active, 'SwMode-Sel'), 3);
pause(0.5);

h = caget(buildpvnames(bpms_active, 'INFOHarmonicNumber-RB'));
nadc = caget(buildpvnames(bpms_active, 'INFOTBTRate-RB'));
nsw = 2*caget(buildpvnames(bpms_active, 'SwDivClk-RB'));

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

bpm_active_ok = false(1,length(bpms_active));
for i=1:length(bpms_active)
    r = bpm_acquire(bpms_active(i), wvf_names, 0, npts(i));
    fft_wvfs = abs(fft(r.wvfs));
    bpm_active_ok(i) = all((fft_wvfs(idx_swharm_p1(i), :)./fft_wvfs(idx_carrier(i), :) > params.swharm_threshold) & (fft_wvfs(idx_swharm_m1(i), :)./fft_wvfs(idx_carrier(i), :) > params.swharm_threshold));
end
bpm_ok = nan(length(bpms),1);
bpm_ok(active) =  double(bpm_active_ok);

caput(buildpvnames(bpms_active, 'SwMode-Sel'), sw_sts);
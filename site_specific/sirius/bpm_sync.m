function [dly_new, dly_orig] = bpm_sync_sp(bpms, toffset, npts)

if nargin < 2 || isempty(toffset)
    toffset = 100;
end

if nargin < 3 || isempty(npts)
    npts = 4096;
end

dly_orig = caget(buildpvnames(bpms, 'ACQTriggerHwDly-SP'));
caput(buildpvnames(bpms, 'ACQTriggerHwDly-SP'), 0);

caput(buildpvnames(bpms, 'ACQSamplesPre-SP'), floor(npts/2))
caput(buildpvnames(bpms, 'ACQSamplesPost-SP'), ceil(npts/2))

caput(buildpvnames(bpms, 'ACQTriggerEvent-Sel'), 2);
caput(buildpvnames(bpms, 'ACQBPMMode-Sel'), 1);
pause(0.2);
caput(buildpvnames(bpms, 'ACQTriggerEvent-Sel'), 0);
pause(0.5);

wvf = cagetwvf(buildpvnames(bpms, 'SP_AArrayData'));
[~, idx_max] = max(wvf);

min_idx_max = min(idx_max);
if toffset > min_idx_max    
    warning('Setting toffset to %d instead of %d to avoid negative delay.', min_idx_max, toffset);
    toffset = min_idx_max;
end

dly_new = idx_max - toffset;

caput(buildpvnames(bpms, 'ACQTriggerHwDly-SP'), dly_new);

caput(buildpvnames(bpms, 'ACQTriggerEvent-Sel'), 2);
pause(0.2);
caput(buildpvnames(bpms, 'ACQTriggerEvent-Sel'), 0);
pause(0.2);
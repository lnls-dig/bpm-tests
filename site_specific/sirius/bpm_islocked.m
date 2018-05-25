function [bpm_ok, raw] = bpm_islocked(bpms, active)

if nargin < 2 || isempty(active)
    active = true(size(bpms));
end

bpms_active = bpms(active);

bpm_active_ok = caget(buildpvnames(bpms_active, 'ADCAD9510PllStatus-Mon')) == 1;
bpm_ok = nan(length(bpms),1);
bpm_ok(active) =  double(bpm_active_ok);

raw = [];
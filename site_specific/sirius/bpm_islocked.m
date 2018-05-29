function [bpm_ok, raw, info] = bpm_islocked(bpms, active)

if nargin < 2 || isempty(active)
    active = true(size(bpms));
end

bpms_active = bpms(active);

bpm_active_ok = caget(buildpvnames(bpms_active, 'ADCAD9510PllStatus-Mon')) == 1;
bpm_ok = nan(length(bpms),1);
bpm_ok(active) =  double(bpm_active_ok);

info.test_name = 'Ref. Clock';
info.version = '1.0.1';

raw.bpm = bpms;
raw.active = active;
raw.pllstatus = bpm_active_ok;  % TODO: replace by matrix with several pll status values
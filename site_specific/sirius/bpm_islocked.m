function [bpm_ok, raw, info] = bpm_islocked(bpms, active)

if nargin < 2 || isempty(active)
    active = true(size(bpms));
end

bpms_active = bpms(active);

% Force loose of lock by changing the PLL reference divider
rdiv = caget(buildpvnames(bpms_active, 'ADCAD9510RDiv-RB'));
caput(buildpvnames(bpms_active, 'ADCAD9510RDiv-SP'), rdiv+5);
pause(0.1);

% Set right PLL reference divider and wait BPM to lock
caput(buildpvnames(bpms_active, 'ADCAD9510RDiv-SP'), rdiv);
pause(3);

bpm_active_ok = caget(buildpvnames(bpms_active, 'ADCAD9510PllStatus-Mon')) == 1;
bpm_ok = nan(length(bpms),1);
bpm_ok(active) =  double(bpm_active_ok);

info.test_name = 'Ref. Clock';
info.version = '1.0.1';

raw.bpm = bpms;
raw.active = active;
raw.rdiv = rdiv;
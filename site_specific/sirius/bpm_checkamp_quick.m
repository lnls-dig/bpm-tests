function bpm_ok = bpm_checkamp_quick(bpms, params, active)

if nargin < 3 || isempty(active)
    active = true(size(bpms));
end

bpms_active = bpms(active);

navg = 10;
pv_names = buildpvnames(bpms_active, {'AmplA-Mon', 'AmplC-Mon', 'AmplB-Mon', 'AmplD-Mon'});

h = mcaopen(pv_names);
data = zeros(1,length(pv_names));
for i=1:navg
    data = data + cageth(h);
    pause(params.period_ms/1e3);
end
mcaclose(h);

data = data/navg;
bpm_active_ok = all(reshape(data, 4, 11)'/params.monit_amp_goal > 1 - params.monit_amp_var_tol_pct/100,2);
bpm_ok = nan(length(bpms),1);
bpm_ok(active) =  double(bpm_active_ok);
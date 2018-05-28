function [bpm_ok, raw] = bpm_checkamp_quick(bpms, params, active)

if nargin < 3 || isempty(active)
    active = true(size(bpms));
end

bpms_active = bpms(active);

navg = 10;
pv_names = buildpvnames(bpms_active, {'AmplA-Mon', 'AmplC-Mon', 'AmplB-Mon', 'AmplD-Mon'});

nvars = 4*length(bpms);
data = zeros(1, nvars);
vars_active = false(1,nvars);
for i=1:4
    vars_active(1,i:4:nvars) = active;
end

nvars_active = length(find(vars_active));

h = mcaopen(pv_names);
for i=1:navg
    data(:, vars_active) = data(:, vars_active) + cageth(h);
    pause(params.period_ms/1e3);
end
mcaclose(h);

if isscalar(params.monit_amp_goal)
    monit_amp_goal = params.monit_amp_goal;
else
    monit_amp_goal = params.monit_amp_goal(:, vars_active);
end

amp = data/navg;
bpm_active_ok = all(reshape(amp(:, vars_active)./monit_amp_goal, 4, nvars_active/4)' > 1 - params.monit_amp_var_tol_pct/100,2);
bpm_ok = nan(length(bpms),1);
bpm_ok(active) =  double(bpm_active_ok);

raw.data = data;
raw.amp = amp;
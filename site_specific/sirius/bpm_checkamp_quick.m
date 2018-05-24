function bpm_ok = bpm_checkamp_quick(bpms, params)

navg = 10;
pv_names = buildpvnames(bpms, {'AmplA-Mon', 'AmplC-Mon', 'AmplB-Mon', 'AmplD-Mon'});

h = mcaopen(pv_names);
data = zeros(1,length(pv_names));
for i=1:navg
    data = data + cageth(h);
    pause(params.period_ms/1e3);
end
mcaclose(h);

data = data/navg;

nbpms = length(bpms);
bpm_ok = false(nbpms,1);
for i=1:nbpms
    pct = data(:, (i-1)*4 + (1:4))/params.monit_amp_goal;
    bpm_ok(i) = all(pct > 1 - params.monit_amp_var_tol_pct/100);
end
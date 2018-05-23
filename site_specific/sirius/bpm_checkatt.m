function [bpms_ac_ok, bpms_ac_nok, bpms_bd_ok, bpms_bd_nok, bpms_inactive] = bpm_checkatt(bpms, params)

h_att_rb = mcaopen(buildpvnames(bpms, 'RFFEAtt-RB'));
h_att_sp = mcaopen(buildpvnames(bpms, 'RFFEAtt-SP'));
bpms_inactive = bpms(h_att_rb == 0);
bpms = bpms(h_att_rb ~= 0);
h_att_rb = h_att_rb(h_att_rb ~= 0);

% Save current attenuator settings
att = cageth(h_att_rb);

h_amp = mcaopen(buildpvnames(bpms, params.monit_amp_pv_names));

namp = length(params.monit_amp_pv_names);

% Use positive variation on attenuator value (increase attenuation).
% If not possible because attenuator value is in its maximum, use negative
% variation (decrease attenuation) instead.
delta_att = repmat(params.delta_att, 1, length(bpms));
delta_att(att >= params.max_att) = -params.delta_att;

r = zeros(length(bpms), namp);
for i=1:length(bpms)
    for j=1:2*params.navg_monit_amp
        if j <= params.navg_monit_amp
            sig = -1;
        else
            sig = 1;
        end
        r(i,:) = r(i,:) + sig*20*log10(cageth(h_amp((i-1)*namp + (1:namp))));

        if j == params.navg_monit_amp
            caputh(h_att_sp(i), att + delta_att);
            pause(0.5);
        else
            pause(params.period_ms/1e3);
        end

    end
end

% Restore attenuator settings
caputh(h_att_sp, att);

if ~isempty(h_att_rb)
    mcaclose(h_att_rb(mcastate(h_att_rb) == 1));
end
if ~isempty(h_att_sp)
    mcaclose(h_att_sp(mcastate(h_att_sp) == 1));
end

% Check channel pairs
r = abs(r/params.navg_monit_amp);
att_ac_ok = all(r(:,1:2) > params.delta_att/2, 2);
att_bd_ok = all(r(:,3:4) > params.delta_att/2, 2);

bpms_ac_ok = bpms(att_ac_ok);
bpms_ac_nok = bpms(~att_ac_ok);
bpms_bd_ok = bpms(att_bd_ok);
bpms_bd_nok = bpms(~att_bd_ok);

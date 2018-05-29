function [bpm_ok, raw, info] = bpm_checkatt(bpms, params, active)

if nargin < 3 || isempty(active)
    active = true(size(bpms));
end

bpms_active = bpms(active);

h_att_rb = mcaopen(buildpvnames(bpms_active, 'RFFEAtt-RB'));
h_att_sp = mcaopen(buildpvnames(bpms_active, 'RFFEAtt-SP'));

% Save current attenuator settings
att = cageth(h_att_rb);

h_amp = mcaopen(buildpvnames(bpms_active, params.monit_amp_pv_names));

namp = length(params.monit_amp_pv_names);

% Use positive variation on attenuator value (increase attenuation).
% If not possible because attenuator value is in its maximum, use negative
% variation (decrease attenuation) instead.
delta_att = repmat(params.delta_att, 1, length(bpms_active));
delta_att(att >= params.max_att) = -params.delta_att;

diff_amp = zeros(length(bpms_active), namp);
for i=1:length(bpms_active)
    for j=1:2*params.navg_monit_amp
        if j <= params.navg_monit_amp
            sig = -1;
        else
            sig = 1;
        end
        diff_amp(i,:) = diff_amp(i,:) + sig*20*log10(cageth(h_amp((i-1)*namp + (1:namp))));

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

% Check channels
diff_amp = abs(diff_amp/params.navg_monit_amp);
bpm_active_ok = all(diff_amp(:,1:4) > params.delta_att/2, 2);
bpm_ok = nan(length(bpms),1);
bpm_ok(active) =  double(bpm_active_ok);

info.test_name = 'Att./Cable';
info.version = '1.0.0';

raw.bpm = bpms;
raw.params = params;
raw.active = active;
raw.att = att;
raw.delta_att = delta_att;
raw.diff_amp = diff_amp;
function [bpm_ok, raw] = bpm_checkamp(bpms, params, active, show_graph)

nbpms = length(bpms);

if nargin < 4 || isempty(show_graph)
    show_graph = true(nbpms,1);
end

show_graph = show_graph & active;

pv_names = buildpvnames(bpms(active), {'AmplA-Mon', 'AmplC-Mon', 'AmplB-Mon', 'AmplD-Mon'});

period_s = params.period_ms/1e3;

h = mcaopen(pv_names);
nvars_active = length(h);

clr = [ ...
    0        0        1
    1        0        0
    0        1        0
    0        0        0.1724
    1        0.1034   0.7241
    1        0.8276   0
    0        0.3448   0
    0.5172   0.5172   1
    0.6207   0.3103   0.2759
    0        1        0.7586
    0        0.5172   0.5862
    0        0        0.4828
    0.5862   0.8276   0.3103
    ];

mrk = { 'o', '*', '+', 'x'};

figure;
ax1 = axes('Position', [0.1 0.12 0.75 0.815]);
ax2 = axes('Position', [1 0.12 0 0.815]);
line(ax2, nan, nan, 'Color', [0 0 0], 'LineWidth', 5);

idx_bpms_show_graph = find(show_graph);
nvars_graph = length(idx_bpms_show_graph)*4;

vars_active = false(1,4*nbpms);
for i=1:4
    vars_active(1,i:4:4*nbpms) = active;
end

vars_show_graph = false(1,nvars_active);
for i=1:4
    vars_show_graph(1,i:4:nvars_active) = show_graph(active);
end

i = 1;
for j=1:nvars_graph/4
    clr_idx = mod(j-1,size(clr,1))+1;
    for k=1:4
        line_handles{i} = line(ax1, nan, nan, 'Color', clr(clr_idx,:), 'LineWidth', 2, 'Marker', mrk{k});
        i = i+1;
    end
    line(ax2, nan, nan, 'Color', clr(clr_idx,:), 'LineWidth', 2);
end

legend(ax2, ['Reference'; bpms(show_graph)]);
set(ax2, 'Visible', 'off');

xlabel(ax1, 'Time [s]');
ylabel(ax1, 'Variation [%]');
grid(ax1, 'on');
title(ax1, 'Markers:    o (ch1/TO)   * (ch2/BI)   + (ch3/TI)   x (ch4/BO)');

line_handles{nvars_graph+1} = line(ax1, nan, nan, 'Color', [0 0 0], 'LineWidth', 5);
line_handles{nvars_graph+2} = line(ax1, nan, nan, 'Color', [0 0 0], 'LineWidth', 5);

yref_inf = 100 - params.monit_amp_var_tol_pct;
yref_sup = 100 + params.monit_amp_var_tol_pct;

t = 1:params.graph_nsamples;
y = nan(params.graph_nsamples, nvars_active);
pct = nan(params.graph_nsamples, nvars_graph);

if isscalar(params.monit_amp_goal)
    monit_amp_goal = params.monit_amp_goal;
else
    monit_amp_goal = params.monit_amp_goal(vars_active);
    monit_amp_goal(monit_amp_goal == 0) = nan;
    monit_amp_goal = monit_amp_goal(vars_show_graph);
end

for i=1:params.graph_nsamples
    try
        y(i,:) = cageth(h);
        pct(i,:) = y(i,vars_show_graph)./monit_amp_goal*100;
        t(i) = (i-1)*period_s;

        for j=1:nvars_graph
            set(line_handles{j}, 'XData', t(1:i), 'YData', pct(1:i,j));
        end

        set(line_handles{nvars_graph+1}, 'XData', t([1 i]), 'YData', [yref_sup yref_sup]);
        set(line_handles{nvars_graph+2}, 'XData', t([1 i]), 'YData', [yref_inf yref_inf]);

        pause(period_s);
    catch
        break
    end
end
mcaclose(h);

bpm_ok = [];

raw.pv_names = pv_names;
raw.t = t;
raw.y = y;
function [bpm_ok, raw, info] = bpm_checkamp(bpms, params, active, show_graph)

nbpms = length(bpms);

if nargin < 4 || isempty(show_graph)
    show_graph = true(nbpms,1);
end

show_graph = show_graph & active;

pv_props = {'AmplA-Mon', 'AmplC-Mon', 'AmplB-Mon', 'AmplD-Mon'};
var_names = {'Ch. 1 / TO / A', 'Ch. 2 / BI / C', 'Ch. 3 / TI / B', 'Ch. 4 / BO / D'};
nvars_per_bpm = length(pv_props);

nbpms_per_fig = 4;
nvars_per_fig = nbpms_per_fig*nvars_per_bpm;

pv_names = buildpvnames(bpms(active), pv_props);

period_s = params.period_ms/1e3;

h = mcaopen(pv_names);
nvars_active = length(h);

clr = [
    0         0.4470    0.7410
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840
    ];

idx_bpms_show_graph = find(show_graph);
nbpms_graph = length(idx_bpms_show_graph);
nvars_graph = nbpms_graph*nvars_per_bpm;
nvars = nbpms*nvars_per_bpm;

nfigs = ceil(nbpms_graph/nbpms_per_fig);
k=1;
for i=1:nfigs
    figure;
    for j=1:nvars_per_fig
        if k > nvars_graph
            break;
        else
            subplot(nbpms_per_fig,nvars_per_bpm,j);
            ax(k) = gca;
            ax_pos(k,:) = get(ax(k), 'Position');
            k=k+1;
        end
    end
end

vars_active = false(1,nvars_per_bpm*nbpms);
for i=1:nvars_per_bpm
    vars_active(1,i:nvars_per_bpm:nvars) = active;
end

vars_show_graph = false(1,nvars_active);
for i=1:nvars_per_bpm
    vars_show_graph(1,i:nvars_per_bpm:nvars_active) = show_graph(active);
end

for i=1:nvars_graph
    line_handles{i} = line(ax(i), nan, nan, 'Color', clr(mod(i,nvars_per_bpm)+1,:), 'LineWidth', 2, 'Marker', '.');
end

for i=1:nvars_per_bpm:nvars_graph
    ylabel(ax(i), {bpms{idx_bpms_show_graph(floor(i/nvars_per_bpm)+1)}, 'Variation [%]'});
end

for i=1:nfigs
    for j=1:nvars_per_bpm
        title(ax((i-1)*nvars_per_fig + j), var_names{j});
    end
end

for i=1:nvars_graph
    txt1 = get(get(ax(i), 'Title'), 'String');
    txt2 = sprintf('Goal: > %0.2g%%', -params.monit_amp_var_tol_pct);
    if ~isempty(txt1)
        txt = {txt1 txt2};
    else
        txt = txt2;
    end
    title(ax(i), txt);
end


% xlabel(ax1, 'Time [s]');
% ylabel(ax1, 'Variation [%]');
% grid(ax1, 'on');

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

tic;
for i=1:params.graph_nsamples
    try
        y(i,:) = cageth(h);
        pct(i,:) = (y(i,vars_show_graph)./monit_amp_goal-1)*100;
        t(i) = (i-1)*period_s;
        for j=1:nvars_graph
            set(line_handles{j}, 'XData', t(1:i), 'YData', pct(1:i,j));
        end

        % FIXME: workaround to avoid Octave plotting bug
        if i==2
            for j=1:nvars_graph
                k = mod(j-1,nvars_per_fig)+1;
                set(ax(j), 'Position', ax_pos(k,:));
            end
        end

        drawnow;
        time_to_wait = period_s - toc;
        if time_to_wait > 0
            pause(time_to_wait);
        end
        tic;
    catch
        break
    end
end
mcaclose(h);

bpm_ok = [];

info.test_name = 'Amplitude Graph';
info.version = '1.1.0';

raw.bpms = bpms;
raw.params = params;
raw.active = active;
raw.pv_names = pv_names;
raw.t = t;
raw.y = y;
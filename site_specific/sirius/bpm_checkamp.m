function [bpm_ok, raw, info] = bpm_checkamp(bpms, params, active, show_graph)

nbpms = length(bpms);

if nargin < 4 || isempty(show_graph)
    show_graph = true(nbpms,1);
end

show_graph = show_graph & active;

pv_names = buildpvnames(bpms(active), {'AmplA-Mon', 'AmplC-Mon', 'AmplB-Mon', 'AmplD-Mon'});

period_s = params.period_ms/1e3;

h = mcaopen(pv_names);
nvars_active = length(h);

clr = lines(4);

idx_bpms_show_graph = find(show_graph);
nbpms_graph = length(idx_bpms_show_graph);
nvars_graph = nbpms_graph*4;

nfigs = ceil(nbpms_graph/4);
k=1;
for i=1:nfigs
    figure;
    for j=1:16
        if k > nvars_graph
            break;
        else
            subplot(4,4,j);
            ax(k) = gca;
            k=k+1;
        end
    end
end

vars_active = false(1,4*nbpms);
for i=1:4
    vars_active(1,i:4:4*nbpms) = active;
end

vars_show_graph = false(1,nvars_active);
for i=1:4
    vars_show_graph(1,i:4:nvars_active) = show_graph(active);
end

for i=1:nvars_graph
    line_handles{i} = line(ax(i), nan, nan, 'Color', clr(mod(i,4)+1,:), 'LineWidth', 2, 'Marker', '.');
end

for i=1:4:nvars_graph
    ylabel(ax(i), {bpms{idx_bpms_show_graph(mod(i,4)+1)}, 'Variation [%]'});
end

for i=1:nfigs
    title(ax((i-1)*16+1), 'Ch. 1 / TO / A');
    title(ax((i-1)*16+2), 'Ch. 2 / BI / C');
    title(ax((i-1)*16+3), 'Ch. 3 / TI / B');
    title(ax((i-1)*16+4), 'Ch. 4 / BO / D');
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

for i=1:params.graph_nsamples
    try
        y(i,:) = cageth(h);
        pct(i,:) = (y(i,vars_show_graph)./monit_amp_goal-1)*100;
        t(i) = (i-1)*period_s;

        for j=1:nvars_graph
            set(line_handles{j}, 'XData', t(1:i), 'YData', pct(1:i,j));
        end
        pause(period_s);
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
function [X,Y,pv_names] = bpm_checkamp(bpms, params)

pv_names = buildpvnames(bpms, {'AmplA-Mon', 'AmplC-Mon', 'AmplB-Mon', 'AmplD-Mon'});

h = mcaopen(pv_names);
nvars = length(h);

clr = [0        0        1
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
       0.5862   0.8276   0.3103];

mrk = { 'o', '*', '+', 'x'};

figure;
ax1 = axes('Position', [0.1 0.12 0.75 0.815]);
ax2 = axes('Position', [1 0.12 0 0.815]);
line(ax2, nan, nan, 'Color', [0 0 0], 'LineWidth', 5);

i = 1;
for j=1:nvars/4
    for k=1:4
        line_handles{i} = line(ax1, nan, nan, 'Color', clr(mod(j,size(clr,1)),:), 'LineWidth', 2, 'Marker', mrk{k});
        i = i+1;
    end

    line(ax2, nan, nan, 'Color', clr(mod(j,size(clr,1)),:), 'LineWidth', 2);
end

legend(ax2, ['Reference'; bpms(:)]);
set(ax2, 'Visible', 'off');

xlabel(ax1, 'samples');
ylabel(ax1, 'Variation [%]');

line_handles{nvars+1} = line(ax1, nan, nan, 'Color', [0 0 0], 'LineWidth', 5);
line_handles{nvars+2} = line(ax1, nan, nan, 'Color', [0 0 0], 'LineWidth', 5);

yref_inf = 100 - params.monit_amp_var_tol_pct;
yref_sup = 100 + params.monit_amp_var_tol_pct;

X = 1:params.graph_nsamples;
Y = nan(params.graph_nsamples, nvars);

ovflw = false;
i = 1;
for sample=1:params.graph_nsamples
     try
        newdata = cageth(h);
        pct = newdata/params.monit_amp_goal*100;
        Y(i,:) = pct;

        X(i) = i;

        if ovflw
            for j=1:nvars
                set(line_handles{j}, 'XData', X, 'YData', Y([i+1:end 1:i],j));
            end

            xs = [0 params.graph_nsamples+1];
        else
            for j=1:nvars
                set(line_handles{j}, 'XData', X(1:i), 'YData', Y(1:i,j));
            end

            xs = [0 i+1];
        end

        set(line_handles{nvars+1}, 'XData', xs, 'YData', [yref_sup yref_sup]);
        set(line_handles{nvars+2}, 'XData', xs, 'YData', [yref_inf yref_inf]);

        pause(params.period_ms/1e3);

        i = mod(i, params.graph_nsamples)+1;

        if ~ovflw && i == params.graph_nsamples
            ovflw = true;
        end
     catch
         break
     end
end    
mcaclose(h);
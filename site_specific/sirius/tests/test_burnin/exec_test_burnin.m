function raw_results = exec_test_burnin(config_path, crate_number, log_filename)

if nargin < 3 || isempty(log_filename)
    fid_logfile = [];
else
    fid_logfile = fopen(log_filename, 'a');
end

fid = [1 fid_logfile];

% Load test parameters
config_filename = fullfile(config_path, 'burnin', 'burnin.cfg');
test_config = readstrlines(config_filename, '%s %s');
for i=1:size(test_config{1},1)
    eval([test_config{1}{i} '=' test_config{2}{i} ';']);
end

monit_amp_var_tol = monit_amp_var_tol_pct/100;
period_s = period_ms/1000;

filetext = readstrlines(fullfile(config_path, 'bpm', sprintf('names_crate%02d.cfg', crate_number)), '%s %s');

allbpms = filetext{1};
bpmtypes = filetext{2};

bpms = allbpms(strcmp(bpmtypes, 'rfbpm-sr') | strcmp(bpmtypes, 'rfbpm-boo') | strcmp(bpmtypes, 'rfbpm-sp'));

% Apply configuration and check which BPMs are alive
logtext(fid, 'trace', 'Applying BPM configurations and checking active units...');
r = configbpm(config_path, crate_number, log_filename);
bpms = r.bpms;


% Check lock to reference clock of RF BPMs
fid = 1;
if ~isempty(bpms)
    logtext(fid, 'trace', 'Checking if BPM clocks are locked to the reference clock sent through the crate backplane...');
    [bpms_locked, bpms_notlocked, bpms_inactive] = bpm_islocked(bpms);
    if isempty(bpms_notlocked)
        logtext(fid, 'info', sprintf('All active BPMs are locked to the reference clock.'), true);
    else
        logtext(fid, 'error', sprintf('Some BPMs are not locked to the reference clock...'), true);
        for i=1:length(bpms_notlocked)
            logtext(fid, 'error', sprintf('Not locked BPM: %s', bpms_notlocked{i}), true);
        end
    end
else
    bpms_locked = [];
    bpms_notlocked = [];
end

% Check switching
if ~isempty(bpms)
    logtext(fid, 'trace', 'Checking if switching works properly...');
    caput(buildpvnames(bpms, 'SwMode-Sel'), 3);
    pause(0.1);
    [bpms_switching, bpms_notswitching] = bpm_checksw(bpms, swharm_threshold);
    if isempty(bpms_notswitching)
        logtext(fid, 'info', sprintf('All active BPMs are switching properly.'));
    else
        logtext(fid, 'error', sprintf('Some BPMs are not switching properly...'));
        for i=1:length(bpms_notswitching)
            logtext(fid, 'error', sprintf('Not switching: %s', bpms_notswitching{i}));
        end
    end
else
    bpms_switching = [];
    bpms_notswitching = [];
end

pv_names = buildpvnames(bpms_locked, {'AmplA-Mon', 'AmplC-Mon', 'AmplB-Mon', 'AmplD-Mon'});

h = mcaopen(pv_names);
nvars = length(h);

clr = lines(nvars);

mrk = { 'o', '*', '+', 'x'};

figure(1);
i = 1;
for j=1:nvars/4
    for k=1:4
        lHandle{i} = line(nan, nan, 'Color', clr(j,:), 'LineWidth', 2, 'Marker', mrk{k});
        i = i+1;
    end
end
xlabel('samples');
ylabel('Variation [dB]');

lHandle{nvars+1} = line(nan, nan, 'Color', [0 0 0], 'LineWidth', 5);
lHandle{nvars+2} = line(nan, nan, 'Color', [0 0 0], 'LineWidth', 5);

yref_inf = 20*log10(1-monit_amp_var_tol);
yref_sup = 20*log10(1+monit_amp_var_tol);

X = 1:graph_nsamples;
Y = nan(graph_nsamples, nvars);

ovflw = false;
i = 1;
while true
    try
        newdata = cageth(h);
        pct = newdata/monit_amp_goal;
        Y(i,:) = 20*log10(pct);

        X(i) = i;

        fprintf('                                  TO/ch1/o      BI/ch2/*      TI/ch3/+      BO/ch4/x  \n', j);
        fprintf('--------------------------------------------------------------------------------------\n', j);
        for j=1:nvars/4
            fprintf('%19s (#%2d)  |', bpms_locked{j}, j);
            for k=1:4
                val = pct(1, (j-1)*4 + k);
                if abs(1-val) > monit_amp_var_tol
                    pattern = ['    ', char(27), '[37;41;1m%9.2f%%', char(27), '[0m'];
                else
                    pattern = '    %9.2f%%';
                end
                fprintf('%s', sprintf(pattern, val*100));
            end
            fprintf('\n');
        end
        fprintf('\n');

        if ovflw
            for j=1:nvars
                set(lHandle{j}, 'XData', X, 'YData', Y([i+1:end 1:i],j));
            end

            xs = [0 graph_nsamples+1];
        else
            for j=1:nvars
                set(lHandle{j}, 'XData', X(1:i), 'YData', Y(1:i,j));
            end

            xs = [0 i+1];
        end

        set(lHandle{nvars+1}, 'XData', xs, 'YData', [yref_sup yref_sup]);
        set(lHandle{nvars+2}, 'XData', xs, 'YData', [yref_inf yref_inf]);

        pause(period_s);

        i = mod(i, graph_nsamples)+1;

        if ~ovflw && i == graph_nsamples
            ovflw = true;
        end
    catch
        break
    end
end

mcaclose(h);

raw_results.monit_amp = Y;
raw_results.t = X*period_s;
raw_results.pv_names = pv_names;
raw.bpms_locked = bpms_locked;
raw.bpms_notlocked = bpms_notlocked;
raw.bpms_switching = bpms_switching;
raw.bpms_notswitching = bpms_notswitching;

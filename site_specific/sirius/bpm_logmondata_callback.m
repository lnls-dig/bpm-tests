function bpm_logmondata_callback(i)

nevnt = mcamonevents(evalin('base', sprintf('h(%d)', i)));

% Discard missed events in first callback since it may be a result of the
% time elapsed between setting up the monitor and effectively starting the
% monitors polling.
if nevnt > 0 && evalin('base', sprintf('iter(%d);', i)) == 0
    nevnt = 1;
end

if nevnt > 1
    warning('Lost %d event(s) in %s.', nevnt-1, evalin('base', sprintf('pvs{%d};', i)));
end

if nevnt > 0
    evalin('base', sprintf([ ...
        'data_temp{%d} = mcacache(h(%d));' ...                          % Consume data fron CA cache
        'data{%d}(:,iter(%d)+(1:%d-1)) = nan(npts(%d),%d-1);' ...       % Fill lost event slots with NaN
        'tstamp{%d}(:,iter(%d)+(1:%d-1)) = nan(7,%d-1);' ...            % Fill lost event slots with NaN
        'data{%d}(:,iter(%d)+%d) = data_temp{%d}(1:npts(%d));' ...      % Fill actual data
        'tstamp{%d}(:,iter(%d)+%d) = mca(60, h(%d));' ...               % Fill actual time stamp
        'iter(%d) = iter(%d) + %d;' ...                                 % Increment iterator
        ], ...
        i, i, ...
        i, i, nevnt, i, nevnt, ...
        i, i, nevnt, nevnt, ...
        i, i, nevnt, i, i, ...
        i, i, nevnt, i, ...
        i, i, nevnt ...
    ));
end
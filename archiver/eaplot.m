function eaplot(pvnames, data, time_utc, timezone, hour_discret)
%EAPLOT   Plot PV data retrieved with eearetrieve.
%
%   eaplot(pvnames, data, time_utc, timezone, hour_discret)
%
%   Inputs:
%       pvnames:        1D cell array of strings or string containing PV names
%       data:           1D cell array of arrays of PV values
%       time_utc:       1D cell array of UTC timestamps in Matlab's date/time format (datenum) corresponding to data
%       timezone:       Local time offset to UTC (ex.: -3 (Brasilia Time- BRT)) - (default value = 0)
%       hour_discret:   Discretization of X-axis ticks in hours unit (default value = 1)
%
%   See also EARETRIEVE.

%   Copyright (C) 2017 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author: Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

% Handle input arguments
if ischar(pvnames)
    pvnames = {pvnames};
end

if nargin < 4 || isempty(timezone)
    timezone = 0;
end

if nargin < 5 || isempty(hour_discret)
    hour_discret = 1;
end

not_empty_indexes = ~cellfun('isempty', data);
data = data(not_empty_indexes);
time_utc = time_utc(not_empty_indexes);
pvnames = pvnames(not_empty_indexes);

npvs = length(pvnames);

% Build plot distinguishable color sequence (requires Image toolbox) 
try
    C = distinguishable_colors(npvs);
catch
    C = lines(npvs);
end

% Plot graphs
time_datenum_current_timezone = cell(npvs,1);

figure;
for i=1:npvs
    time_datenum_current_timezone{i} = time_utc{i} + timezone/24;
    
    % Find discontinuity in timestamps by looking for time gaps 3 times
    % greater the median sample time value. Mark data just after
    % discontinuity as NaN for better plotting. Time resolution for
    % computing median is 0.1 second.
    diff_t = round(diff(time_datenum_current_timezone{i})*864000)/10;
    discont = find(diff_t > 3*median(diff_t)) + 1;
    data{i}(discont) = NaN;
    
    h = plot(time_datenum_current_timezone{i}, data{i}, 'Color', C(i,:,:));
    hold on
    
    % Store PV name on graph for future use in datatip text
    set(h, 'UserData', pvnames{i});
end

% Determine edge timestamps
minmax_date = zeros(npvs, 2);
for i=1:npvs
    if length(time_datenum_current_timezone{i}) > 1
        minmax_date(i,:) = time_datenum_current_timezone{i}([2 end]);
    else
        minmax_date(i,:) = [Inf -Inf];
    end
end

min_date = min(minmax_date(:,1));
max_date = max(minmax_date(:,2));

% Use hour discretization for edge timestamps
start_time_datenum_rounded = floor(min_date*24)/24;
end_time_datenum_rounded = ceil(max_date*24)/24;

% Build graph ticks and tick labels
ticks = start_time_datenum_rounded:hour_discret/24:end_time_datenum_rounded;

tick_labels = cell(length(ticks),1);
for i=1:length(ticks)
    tick_labels{i} = datestr(ticks(i), 'HH:MM');
end

set(gca, 'XTick', ticks)
set(gca, 'XTickLabelMode', 'manual')
set(gca, 'XTickLabel', tick_labels)

ax = axis;
axis([ticks(1) ticks(end) ax(3:4)]);

% datetick('x','HH:MM')

grid on;

% Set datatip show function (works only in Matlab)
try
    dcm_obj = datacursormode(gcf);
    set(dcm_obj,'enable','on')
    set(dcm_obj,'UpdateFcn', @update_datatip)
end

legend(pvnames);

title(sprintf('Start Date: %s - End Date: %s', datestr(ticks(1), 'yyyy-mm-dd'), datestr(ticks(end), 'yyyy-mm-dd')));


% --- Auxiliary functions ---

% Datatip text generation function
function outtxt = update_datatip(obj, event_obj)

userdata = get(get(event_obj,'Target'), 'UserData');
pos = get(event_obj,'Position');
outtxt = {userdata, sprintf('Time = %s', datestr(pos(1), 'HH:MM:ss.FFF (yyyy/mm/dd)')), sprintf('Value = %g', pos(2))};
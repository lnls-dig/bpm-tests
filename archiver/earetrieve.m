function [data, time_utc] = earetrieve(address, pvnames, start_date, duration, timezone)
%EARETRIEVE   Retrieve PV data from EPICS Archiver Appliance.
%
%   [data, time_utc] = earetrieve(address, pvnames, start_date, duration, timezone)
%
%   Inputs:
%       address:        EPICS Archiver Appliance address (ex.: 'http://127.0.0.1:11998')
%       pvnames:        1D cell array of strings or string containing PV names to be retrieved from the archiver
%       start_date:     Timestamp of starting date in the format year-month-day hours:minutes:seconds (ex.: '2017-06-08 23:00:00')
%       duration:       Time length of data expressed in hours
%       timezone:       Local time offset to UTC (ex.: -3 (Brasilia Time- BRT)) - (default value = 0)
%
%   Outputs:
%       data:           1D cell array of arrays of PV values
%       time_utc:       1D cell array of UTC timestamps in Matlab's date/time format (datenum)

%   Copyright (C) 2017 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author: Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

% Handle input arguments
if ischar(pvnames)
    pvnames = {pvnames};
end

npvs = length(pvnames);

if nargin < 6 || isempty(timezone)
    timezone = 0;
end

% Convert 'start_date' to Matlab datenum
start_date_datenum = datenum(start_date) - timezone/24;

% Build start and end date/hour strings in the format used by the EPICS Archiver Appliance
start_date_str = datestr(start_date_datenum, 'yyyy-mm-ddTHH:MM:ss.FFFZ');
end_date_str = datestr(start_date_datenum + duration/24, 'yyyy-mm-ddTHH:MM:ss.FFFZ');

utc_offset = datenum('01-jan-1970 00:00:00');
data = cell(npvs,1);
time_utc = cell(npvs,1);

for i=1:npvs
    try
        urlwrite(sprintf('%s/retrieval/data/getData.mat', address), 'temp.mat', 'get', ...
            {'pv', pvnames{i}, 'from', start_date_str, 'to', end_date_str});
        wrkspc = load('temp.mat');
        
        data{i} =  wrkspc.data.values;
        seconds =  wrkspc.data.epochSeconds;
        nanoseconds = wrkspc.data.nanos;
        
        % Convert UTC timestamp to Matlab 
        time_utc{i} = utc_offset + 1/86400*(double(seconds) + double(nanoseconds)/1e9);
    catch
        warning('earetrieve:pvnotfound', 'Could not retrieve data from EPICS Archiver for PV %s.\n', pvnames{i});
    end
    
end

delete('temp.mat');
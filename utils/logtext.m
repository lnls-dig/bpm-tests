function logtext(varargin)
%LOGTEXT   Write text to log file (or screen).
%   LOGTEXT(text)
%   LOGTEXT(fid, text)
%   LOGTEXT(fid, level, text)

%   Copyright (C) 2017 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author (Jul-2017): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

if nargin == 1
    fid = 1;
    level = 0;
    text = varargin{1};
elseif nargin == 2
    fid = varargin{1};
    level = 0;
    text = varargin{2};
elseif nargin == 3
    fid = varargin{1};
    level = varargin{2};
    text = varargin{3};
end

level_table = { ...
    'TRACE', 'trace';   ...
    'INFO',  'info';    ...
    'WARN',  'warning'; ...
    'ERR',   'error';   ...
    'FATAL', 'fatal';   ...
    };

leveltxt = level_table{1,1};
for i=1:length(level_table)
    if (ischar(level) && strcmpi(level, level_table{i,2})) || (isnumeric(level) && level == i-1)
        leveltxt = level_table{i,1};
        break;
    end
end

for i=1:length(fid)
    fprintf(fid(i), '%-5s: [%s] %s\n', leveltxt, datestr(now, 'yy-mm-dd HH:MM:SS'), text);
end
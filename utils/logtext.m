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
    colorized = false;
elseif nargin == 2
    fid = varargin{1};
    level = 0;
    text = varargin{2};
    colorized = false;
elseif nargin == 3
    fid = varargin{1};
    level = varargin{2};
    text = varargin{3};
    colorized = false;
elseif nargin == 4
    fid = varargin{1};
    level = varargin{2};
    text = varargin{3};
    colorized = varargin{4};
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
        levelnum = i;
        break;
    else
        levelnum = -1;
    end
end

for i=1:length(fid)
    if colorized && fid(i) == 1
        if levelnum > 2
            pre = [char(27), '[31m'];
            post = [char(27), '[0m'];
        elseif levelnum > 3
            pre = [char(27), '[33m'];
            post = [char(27), '[0m'];
        elseif levelnum > 4
            pre = [char(27), '[33m'];
            post = [char(27), '[0m'];
        else
            pre = '';
            post = '';
        end
    else
        pre = '';
        post = '';
    end

    fprintf(fid(i), [pre '%-5s: [%s] %s' post '\n'], leveltxt, datestr(now, 'yy-mm-dd HH:MM:SS'), text);
end
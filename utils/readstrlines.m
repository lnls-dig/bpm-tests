function textfromfile = readstrlines(filename, pattern)
%READSTRLINES   Read text file according to pattern.
%   textfromfile = READSTRLINES(filename, pattern)

%   Copyright (C) 2017 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author (Jul-2017): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

if nargin < 2
    pattern = '%s';
end

fid = fopen(filename);
textfromfile = textscan(fid, pattern, 'CommentStyle', '#');
fclose(fid);

if length(textfromfile) == 1
    textfromfile = textfromfile{1};
end
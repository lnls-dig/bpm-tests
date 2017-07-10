function logcondition(fid, condition, lhs_text, op_text, rhs_text)
%LOGCONDITION   Write text to log when one or more conditions are satisfied.
%   LOGCONDITION(fid, condition, lhs_text, op_text, rhs_text)
%
%   See also LOGTEXT.

%   Copyright (C) 2017 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author (Jul-2017): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

if ischar(lhs_text)
    lhs_text = {lhs_text};
end

if ischar(rhs_text)
    rhs_text = {rhs_text};
end

if ischar(op_text)
    op_text = {op_text};
end
    
if length(op_text) == 1
    op_text = repmat(op_text, length(condition), 1);
end

for i=1:length(condition)
    if condition(i)
        logtext(fid, 'trace', sprintf('%s %s %s.', lhs_text{i}, op_text{i},  rhs_text{i}));
    end
end
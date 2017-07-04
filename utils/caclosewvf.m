function caclosewvf(handles)
%CACLOSEWVF   Close connection to wafevorm PVs.
%
%   caclosewvf(handles)
%
%   See also CAGETWVFH, CACLOSEWVF.

%   Copyright (C) 2017 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author (Jun-2017): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

f = fieldnames(handles);

for i=1:length(f)
    h = handles.(f{i});
    h = h(h ~= 0);    
    mcaclose(h);
end
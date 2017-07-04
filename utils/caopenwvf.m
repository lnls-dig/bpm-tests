function handles = caopenwvf(pvnames)
%CAOPENWVF   Open connection to wafevorm PVs.
%
%   handles = caopenwvf(pvnames)
%
%   See also CAGETWVFH, CACLOSEWVF.

%   Copyright (C) 2017 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author (Jun-2017): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

if ischar(pvnames)
    pvnames = {pvnames};
end

pvnord = cellfun(@horzcat, pvnames, repmat({'.NORD'}, 1, length(pvnames)), 'UniformOutput', 0);

handles = struct('val', mcaopen(pvnames), 'nord', mcaopen(pvnord));
function pvnames = buildpvnames(pvprefixes, pvsuffixes, separator)
%BUILDPVNAMES   Concatenate PV prefixes and suffixes.
%   Concatenate all combinations of PV prefixes and suffixes to form a
%   list of PV names.
%
%   pvnames = buildpvnames(pvprefixes, pvsuffixes, separator)
%
%   INPUTS:
%       pvprefixes: 1D cell array of strings containing PV prefixes.
%                   It can be a string if only one PV prefix is to be
%                   specified.
%       pvsuffixes: 1D cell array of strings containing PV suffixes. It
%                   can be a string if only one PV suffix is to be
%                   specified.
%       separator:  Separator string of PV name parts, typically a ':'
%                   character (default value = ':').
%
%   OUTPUTS:
%       pvnames:    1D cell array of string containing PV names. The
%                   combination order of PV prefixes and suffixes is
%                   such that prefixes are first repeated for each
%                   suffix.
%

%   Copyright (C) 2017 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author (Jun-2017): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

if nargin < 3
    separator = ':';
end

if ischar(pvprefixes)
    pvprefixes = {pvprefixes};
end

if ischar(pvsuffixes)
    pvsuffixes = {pvsuffixes};
end

ndev = length(pvprefixes);
nprop = length(pvsuffixes);

pvprefixes = pvprefixes(:)';
pvsuffixes = pvsuffixes(:)';

separator = repmat({separator}, 1, nprop);
pvnames = cell(1,ndev*nprop); 
for i=1:ndev
    pvnames((i-1)*nprop + (1:nprop)) = cellfun(@horzcat, repmat(pvprefixes(i), 1, nprop), separator, pvsuffixes, 'UniformOutput', 0);
end

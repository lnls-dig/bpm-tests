function [values, notfound] = caget(pvnames)
%CAGET   EPICS CA get.
%   EPICS CA get using PV names as input argument.
%   Every call of CAGET opens and closes the connection to the PVs. For
%   performance, prefer using the function cageth.
%
%   [values, notfound] = caget(pvnames)
%
%   INPUTS:
%       pvnames:    1D cell array of strings containing PV names. It can
%                   be a string if only one PV is to be specified.
%
%   OUTPUTS:
%       values:     1D array of PV values. For PVs which could not be
%                   open, a NaN value is returned.
%       notfound:   Indexes of PVs which could not be open.
%
%   See also CAGETH, CAPUT, MCAGET.

%   Copyright (C) 2017 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author (Jun-2017): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

handles = mcaopen(pvnames);
[values, notfound] = cageth(handles, false);
mcaclose(handles(handles ~= 0));
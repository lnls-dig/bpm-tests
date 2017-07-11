function status = caput(pvnames, values)
%CAPUT   EPICS CA put.
%   EPICS CA put using PV names as input argument.
%   Every call of CAPUT opens and closes the connection to the PVs. For
%   performance, prefer using the function caputh.
%
%   [status, notfound] = caput(pvnames, values)
%
%   INPUTS:
%       pvnames:    1D cell array of strings containing PV names. It can
%                   be a string if only one PV is to be specified.
%       values:     1D array of PV values to be set. If a scalar value
%                   is specified, all PVs are set to that value.
%
%   OUTPUTS:
%       status:     Same meaning as in mcaput function, i.e., status = 1 in
%                   case of success and status = 0 otherwise. Additionaly,
%                   PVs which could not be open result in a failure status.
%
%   See also CAPUTH, CAGET, MCAPUT.

%   Copyright (C) 2017 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author (Jun-2017): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

handles = mcaopen(pvnames);
status = caputh(handles, values);
mcaclose(handles(handles ~= 0));
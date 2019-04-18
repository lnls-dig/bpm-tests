function status = caputh(handles, values, checkstate)
%CAPUTH   EPICS CA put using handles.
%   EPICS CA put using MCA handles as input argument.
%   To generate valid handles, use mcaopen. CAPUTH outperforms the caput
%   function as it does not need to open and close the PV connections every
%   call.
%
%   status = caputh(handles, values, checkstate)
%
%   INPUTS:
%       handles:    1D array of MCA PV handles.
%       values:     1D array of PV values to be set. If a scalar value
%                   is specified, all PVs are set to that value.
%       checkstate: If true, checks connection to each PV before performing
%                   mcaget and only issues CA get to the active PVs. If
%                   false, applies mcaget without checking
%                   (default = true).
%
%   OUTPUTS:
%       status:     Same meaning as in mcaput function, i.e., status = 1 in
%                   case of success and status = 0 otherwise. Additionaly,
%                   PVs which could not be open result in a failure status.
%
%   See also CAPUTH, CAGET, MCAPUT, MCAOPEN, MCACLOSE.

%   Copyright (C) 2017 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author (Jun-2017): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

if nargin < 3 || isempty(checkstate)
    checkstate = 1;
end

npvs = length(handles);

if length(values) == 1
    values = repmat(values, 1, npvs);
end

valid = handles ~= 0;

values = values(valid);
handles = handles(valid);

status = zeros(1,npvs);
if ~isempty(handles)
    if checkstate
        handles_cell = num2cell(handles);
        pvactive = mcastate(handles_cell{:}) == 1; % valid must be 'logical' variable
        values = values(pvactive);
        handles = handles(pvactive);
        valid(valid) = pvactive;
    end
    status(valid) = mcaput(handles, values);
end

function [values, notfound] = cageth(handles, checkstate)
%CAGETH   EPICS CA get using handles.
%   EPICS CA get using MCA handles as input argument.
%   To generate valid handles, use mcaopen. CAGETH outperforms the caget
%   function as it does not need to open and close the PV connection every
%   call.
%
%   [values, notfound] = cageth(handles, checkstate)
%
%   INPUTS:
%       handles:    1D array of MCA PV handles.
%       checkstate: If true, checks connection to each PV before performing
%                   mcaget and only issues CA get to the active PVs. If
%                   false, applies mcaget without checking
%                   (default = true).    
%
%   OUTPUTS:
%       values:     1D array of PV values. For PVs which could not be
%                   open, a NaN value is returned.
%       notfound:   Indexes of PVs which could not be open.
%
%   See also CAGET, CAPUT, MCAGET, MCAOPEN, MCACLOSE.

%   Copyright (C) 2017 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author (Jun-2017): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

if nargin < 2 || isempty(checkstate)
    checkstate = 1;
end

npvs = length(handles);

valid = handles ~= 0;
notfound = find(handles == 0);

handles = handles(valid);

values = nan(1,npvs);
if ~isempty(handles)
    if checkstate
        handles_cell = num2cell(handles);
        pvactive = mcastate(handles_cell{:}) == 1; % valid must be 'logical' variable
        handles = handles(pvactive);
        valid(valid) = pvactive;
    end    
    values(valid) = mcaget(handles);
end




function status = caputwvf(pvnames, wvfdata)
%CAPUTWVF   EPICS CA put for waveforms.
%   EPICS CA put using waveform PV names as input arguments.
%   Every call of CAPUTWVF opens and closes the connection to the PVs. For
%   performance, prefer using the function cagetwvfh.
%
%   status = caputwvf(pvnames, wvfdata)
%
%   INPUTS:
%       pvnames:    1D cell array of strings containing waveform PV names.
%                   It can be a string if only one PV is to be specified.
%       wvfdata:    2D array of waveform PV values to be set, where
%                   each column corresponds to the PV of same index.
%
%   OUTPUTS:
%       status:     Same meaning as in mcaput function, i.e., status = 1 in
%                   case of success and status = 0 otherwise. Additionaly,
%                   PVs which could not be open result in a failure status.
%
%   See also CAPUT, MCAPUT.

%   Copyright (C) 2019 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author (Apr-2019): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

handles = caopenwvf(pvnames);
status = caputwvfh(handles, wvfdata, false);
caclosewvf(handles);
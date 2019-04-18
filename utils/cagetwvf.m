function wvfdata = cagetwvf(pvnames)
%CAGETWVF   EPICS CA get for waveforms.
%   EPICS CA get using waveform PV names as input arguments. Only waveforms
%   of same lengths and non-zero length will be returned. The NORD record
%   is used to determine the number of samples to be read from a waveform
%   PV.
%   Every call of CAGETWVF opens and closes the connection to the PVs. For
%   performance, prefer using the function cagetwvfh.
%
%   wvfdata = cagetwvf(pvnames)
%
%   INPUTS:
%       pvnames:    1D cell array of strings containing waveform PV names.
%                   It can be a string if only one PV is to be specified.
%
%   OUTPUTS:
%       wvfdata:    2D array of waveform PV values, where each column
%                   corresponds to the PV of same index. For invalid
%                   waveform PVs (not found, not connected or zero-length
%                   waveform) an array of NaN values is returned in the
%                   corresponding matrix column.
%
%   See also CAGET, MCAGET.

%   Copyright (C) 2017 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author (Jun-2017): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

handles = caopenwvf(pvnames);
wvfdata = cagetwvfh(handles, false);
caclosewvf(handles);

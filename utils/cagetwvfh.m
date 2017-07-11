function [wvfdata, notfound] = cagetwvfh(handles, checkstate)
%CAGETWVFH   EPICS CA get for waveforms using handles.
%   EPICS CA get using waveform MCA handles as input argument. Only
%   waveforms of same lengths and non-zero length will be returned.
%   The NORD record is used to determine the number of samples to be read
%   from a waveform PV.
%
%   [wvfdata, notfound] = cagetwvfh(handles, checkstate)
%
%   INPUTS:
%       handles:    1D array of MCA waveform PV handles. To generate valid
%                   waveform handles, use caopenwvf.
%       checkstate: If true, checks connection to each PV before performing
%                   mcaget and only issues CA get to the active PVs. If
%                   false, applies mcaget without checking
%                   (default = true).
%   OUTPUTS:
%       wvfdata:    2D array of waveform PV values, where each column
%                   corresponds to the PV of same index. For invalid
%                   waveform PVs (not found, not connected or zero-length
%                   waveform) an array of NaN values is returned in the
%                   corresponding matrix column.
%       notfound:   Indexes of PVs which could not be open.
%
%   See also CAOPENWVF, CACLOSEWVF, CAGET, MCAGET.

%   Copyright (C) 2017 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author (Jun-2017): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

npvs = length(handles.val);

wvfdata = [];

% Filter out null handles
valid = handles.nord ~= 0;
notfound = find(handles.nord == 0);
handles.nord = handles.nord(valid);

nelem = nan(1,npvs);
if ~isempty(handles.nord)
    if checkstate
        % Ignore disconnected PVs to avoid error when using 'mcaget'
        handles_nord_cell = num2cell(handles.nord);
        pvactive = mcastate(handles_nord_cell{:}) == 1; % valid must be a 'logical' variable
        handles.nord = handles.nord(pvactive);
        valid(valid) = pvactive;
    end
    nelem(valid) = mcaget(handles.nord);
    
    % Check for waveforms with zero length and mark them as not valid
    valid((nelem == 0) | isnan(nelem)) = false;
    
    if any(valid)
        % Check if all waveforms have the same number of points to be read and
        % issue an error if not.
        npts = nelem(valid);
        if any(npts ~= npts(1))
            error('cagetwvf:numberofelem', 'Number of elements of all waveforms should be identical.');
        end
        
        npts = npts(1);
        
        indexes_handles_valid = find(valid);
        
        wvfdata = nan(npts, npvs);
        for i=1:npvs
            handle = handles.val(i);
            if valid(i) && (mcastate(handle) == 1)
                try
                    rawdata = mcaget(handle);
                    wvfdata(:,i) = rawdata(1:npts);
                catch
                    valid(i) = false;
                end
            else
                valid(i) = false;
            end
        end
    end
end
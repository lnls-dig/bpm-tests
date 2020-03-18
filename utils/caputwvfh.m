function status = caputwvfh(handles, wvfdata, checkstate)
%CAPUTWVFH   EPICS CA put for waveforms using handles.
%   EPICS CA put using waveform MCA handles as input argument.
%
%   status = caputwvfh(handles, wvfdata, checkstate)
%
%   INPUTS:
%       handles:    1D array of MCA waveform PV handles. To generate valid
%                   waveform handles, use caopenwvf.
%       wvfdata:    2D array of waveform PV values to be set, where
%                   each column corresponds to the PV of same index.
%       checkstate: If true, checks connection to each PV before performing
%                   mcaput and only issues CA put to the active PVs. If
%                   false, applies mcaput without checking
%                   (default = true).
%
%   OUTPUTS:
%       status:     Same meaning as in mcaput function, i.e., status = 1 in
%                   case of success and status = 0 otherwise. Additionaly,
%                   PVs which could not be open result in a failure status.
%
%   See also CAOPENWVF, CACLOSEWVF, CAGETWVFH, CAGET, MCAGET.

%   Copyright (C) 2019 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author (Apr-2019): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

if nargin < 3 || isempty(checkstate)
    checkstate = 1;
end

npvs = length(handles.val);

if size(wvfdata,2) == 1
    wvfdata = repmat(wvfdata, 1, npvs);
end

valid = handles.val ~= 0;

wvfdata = wvfdata(:,valid);
handles.val = handles.val(valid);

status = zeros(1,npvs);
if ~isempty(handles.val)
    if checkstate
        handles_cell = num2cell(handles.val);
        pvactive = mcastate(handles_cell{:}) == 1; % valid must be 'logical' variable
        wvfdata = wvfdata(:,pvactive);
        handles.val = handles.val(pvactive);
        valid(valid) = pvactive;
    end
    validd = find(valid);
    for i=1:length(handles.val)
        nelem = mcaget(handles.nelm);
        if nelem < size(wvfdata,1)
            warning('caputwvf:numberofelem', sprintf('Waveform PV %d has less number of elements than the waveform being set. The extra values were ignored.', i));
        end
        status(validd(i)) = mcaput(handles.val(i), wvfdata(:,i));
    end
end
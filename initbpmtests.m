function initbpmtests
%INITBPMTESTS   Initialize the BPM Tests Toolbox.

%   Copyright (C) 2017 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author (Jul-2017): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

dirinfo = dir;

% Ignore paths starting with a dot. For example, '.', '..', '.git'
for i=1:length(dirinfo)
    if dirinfo(i).isdir && dirinfo(i).name(1) ~= '.'
        addpath(genpath(fullfile(pwd, dirinfo(i).name)));
    end
end

mcatimeout('open', 1);
mcatimeout('get', 0.5);
mcatimeout('put', 0.5);
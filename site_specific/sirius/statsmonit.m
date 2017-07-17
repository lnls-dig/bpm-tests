% From bpm-tests directory, call:
%   procServ -n [PROCESS NAME] -i ^C^D [TELNET PORT] [OCTAVE EXECUTABLE DIRECTORY]octave-cli -qf site_specific/sirius/statsmonit.m'
%
%   Substitute [PROCESS NAME], [TELNET PORT] and [OCTAVE EXECUTABLE DIRECTORY] by appropriate names, for instance:
%       [PROCESS NAME] = statsmonit
%       [TELNET PORT] = 3000
%       [OCTAVE EXECUTABLE DIRECTORY] = /usr/bin/

%   Copyright (C) 2017 CNPEM
%   Licensed under GNU Lesser General Public License v3.0 (LGPL)
%
%   Author (Jul-2017): Daniel Tavares (LNLS/DIG) - daniel.tavares@lnls.br

% SCRIPT PARAMETERS
mean_length = 20;
acqch = 3; % [0] adc - [1] adcswap - [2] tbt - [3] fofb
npts = 100000;
period = 5;
logfilename = fullfile('site_specific', 'sirius', 'logs', 'statsmonit.log');
mcapaths = '/usr/local/epics/extensions/lib/linux-x86_64:/usr/local/epics/extensions/src/mca/matlab';
datadir = fullfile('site_specific', 'sirius', 'data');

% SCRIPT

% Disable MCA warnings to avoid messing up log file
warning('off');

% Set path and other initializations
basepath = pwd;
if ~strcmpi(basepath(end-8:end), 'bpm-tests')
    error('statsmonit:wrongPath', 'Wrong base path. The base path must be the location of ''bpm-tests''.');
end
addpath(mcapaths);
initbpmtests;

bpmacqparamnames = {'ACQChannel', 'ACQSamplesPre', 'ACQSamplesPost', 'ACQShots', 'ACQTriggerRep', 'ACQTrigger'};
bpmparavalues = [acqch npts 0 1 0 0];

bpmwaveformnames = {'GEN_AArrayData', 'GEN_BArrayData', 'GEN_CArrayData', 'GEN_DArrayData', 'GEN_XArrayData', 'GEN_YArrayData', 'GEN_QArrayData', 'GEN_SUMArrayData'};
acqtriggername = 'ACQTriggerEvent';

% File descriptor for writing log to screen (fid = 1)
fidlog = 1;

try
    while true
        bpms_filename = fullfile('site_specific', 'sirius', 'config', 'bpm', 'names.cfg');
        logtext(fidlog, 'trace', sprintf('Loading BPM names from file ''%s''...', bpms_filename));
        
        bpmnames = readstrlines(bpms_filename);
        nbpms = length(bpmnames);
        
        % Try to CA put only the first BPM parameter to probe which BPMs are accessible
        activebpms = caput(buildpvnames(bpmnames, bpmacqparamnames(1)), repmat(bpmparavalues(1), 1, nbpms));
        inactive_bpmnames = bpmnames(activebpms == 0);
        
        % Update the list of active BPM names and CA put the rest of BPM parameters
        bpmnames = bpmnames(activebpms == 1);
        nbpms = length(bpmnames);
        caput(buildpvnames(bpmnames, bpmacqparamnames(2:end)), repmat(bpmparavalues(2:end), 1, nbpms));
        
        % Report active BPMs
        for i=1:length(bpmnames)
            logtext(fidlog, 'trace', sprintf('Found BPM %s.', bpmnames{i}));
        end
        
        % Report inactive BPMs
        for i=1:length(inactive_bpmnames)
            logtext(fidlog, 'info', sprintf('BPM %s NOT FOUND.', inactive_bpmnames{i}));
        end
        
        if ~isempty(bpmnames)
            % Report aqcuisition parameters that have been set
            paramtext = '';
            for i=1:length(bpmacqparamnames)
                paramtext = [paramtext sprintf('%s = %d', bpmacqparamnames{i}, bpmparavalues(i))];
                if i ~= length(bpmacqparamnames)
                    paramtext = [paramtext '; '];
                else
                    paramtext = [paramtext '.'];
                end
            end
            logtext(fidlog, 'trace', ['Acquisition parameters to be set to all active BPMs: ' paramtext]);
            
            % Load monitoring parameters
            monitstatus_filename = fullfile('site_specific', 'sirius', 'config', 'statsmonit', 'monitored.cfg');
            textfromfile = readstrlines(monitstatus_filename, '%s %f');
            monitstatsnames = textfromfile{1}';
            monitstatspct = repmat(textfromfile{2}'/100, 1, nbpms);
            monitstatspct_txt = cellfun(@sprintf, repmat({'%d%% variation'}, 1, length(monitstatspct)) , num2cell(monitstatspct*100), 'UniformOutput', 0);
            nmonits = length(monitstatsnames);
            
            % Open MCA handles for BPM monitoring parameters, waveforms and acquisition trigger PVs
            pv_monitstats = buildpvnames(bpmnames, monitstatsnames);
            pv_waveforms = buildpvnames(bpmnames, bpmwaveformnames);
            
            handles_monitstats = mcaopen(pv_monitstats);
            handles_waveforms = caopenwvf(pv_waveforms);
            handles_acqtrigger = mcaopen(buildpvnames(bpmnames, acqtriggername));
            
            acqtrigvalue = zeros(1,length(handles_acqtrigger));
            
            % Run acquisition loop while BPM names file has not changed
            logtext(fidlog, 'trace', sprintf('Started periodic acquisitions every %g seconds.', period));
            
            iter = 0;
            nsuccess = 1;
            monitvalues_table = zeros(mean_length, nbpms*nmonits);
            fileinfo_previous = dir(bpms_filename);
            fileinfo_current = fileinfo_previous;
            while (fileinfo_previous.datenum == fileinfo_current.datenum) && nsuccess > 0
                activebpms = caputh(handles_acqtrigger, acqtrigvalue);
                nsuccess = length(find(activebpms == 1));
                
                % Report inactive BPMs
                if nsuccess ~= nbpms
                    logtext(fidlog, 'warning', sprintf('%d BPMs are inactive.', nbpms - nsuccess));
                end
                
                % CA get monitoring PVs and store returned values into matrix for mean calculation of the past 'mean_length' samples
                monitvalues = cageth(handles_monitstats);
                
                % Perform analysis only after first 'mean_length' iterations
                if iter < mean_length
                    monitvalues_table(mod(iter,mean_length)+1,:) = monitvalues;
                    iter = iter+1;
                else
                    monitstatsrefvalue = mean(monitvalues_table);
                    
                    % Condition to be satisfied for storing waveforms
                    monitcondition_greater = monitvalues./monitstatsrefvalue > 1+monitstatspct;
                    monitcondition_lesser = monitvalues./monitstatsrefvalue < 1-monitstatspct;
                    
                    if any(monitcondition_greater) || any(monitcondition_lesser)
                        % In case one of the monitored conditions has been triggered, save waveforms
                        logcondition(fidlog, monitcondition_greater, pv_monitstats, '>', monitstatspct_txt);
                        logcondition(fidlog, monitcondition_lesser, pv_monitstats, '<', monitstatspct_txt);
                        
                        wvf = cagetwvfh(handles_waveforms, 1);
                        save(fullfile(datadir, sprintf('%s_waveforms.mat', datestr(now, 30))), 'wvf', 'monitvalues', 'monitstatsrefvalue', 'monitstatspct', 'pv_monitstats', 'pv_monitstats', '-mat');
                    else
                        % Only aquisitions which have not triggered saving of waveforms contributes to mean of monitored parameters
                        monitvalues_table(mod(iter,mean_length)+1,:) = monitvalues;
                        iter = iter+1;
                    end
                end
                
                pause(period);
                fileinfo_previous = fileinfo_current;
                fileinfo_current = dir(bpms_filename);
            end
            
            % Close all MCA handles
            handles_acqtrigger = handles_acqtrigger(handles_acqtrigger ~= 0);
            mcaclose(handles_acqtrigger(mcastate(handles_acqtrigger) == 1));
            
            handles_monitstats = handles_monitstats(handles_monitstats ~= 0);
            mcaclose(handles_monitstats(mcastate(handles_monitstats) == 1));
            
            caclosewvf(handles_waveforms);
        end
    end
catch err
    for i=1:length(fidlog)
        if all(fidlog(i) ~= [1 2]) % Do not close standard output or error output
            fclose(fidlog(i));
        end
    end
    rethrow(err);
end

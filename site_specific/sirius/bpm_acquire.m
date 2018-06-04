function r = bpm_acquire(bpm_names, wvf_names, acqch, npts, n, pause_period)

if ~iscell(bpm_names)
    bpm_names = {bpm_names};
end

if ~iscell(wvf_names)
    wvf_names = {wvf_names};
end

if nargin < 5
    n = 1;
    pause_period = 0;
elseif nargin < 6
    pause_period = 1;
end

acq_param_values = { ...
    'ACQChannel-Sel',       acqch; ...
    'ACQSamplesPre-SP',     npts; ...
    'ACQSamplesPost-SP',    0; ...
    'ACQShots-SP',          1;  ...
    'ACQTriggerRep-Sel',    0;  ...
    'ACQTrigger-Sel',       0;  ...
    };

acq_trigger_name = 'ACQTriggerEvent-Sel';

% Try to CA put only the first BPM parameter to probe which BPMs are accessible
active_bpms = caput(buildpvnames(bpm_names, acq_param_values(1,1)), repmat(acq_param_values{1,2}, 1, length(bpm_names)));

% Update the list of active BPM names and CA put the rest of BPM parameters
active_bpms = bpm_names(active_bpms == 1);
nbpms = length(active_bpms);
caput(buildpvnames(active_bpms, acq_param_values(2:end,1)), repmat(cell2mat(acq_param_values(2:end,2)), 1, nbpms));

if ~isempty(active_bpms)
    % Open MCA handles for BPM monitoring parameters, waveforms and acquisition trigger PVs
    pv_names = buildpvnames(active_bpms, wvf_names);

    handles_waveforms = caopenwvf(pv_names);
    handles_acqtrigger = mcaopen(buildpvnames(active_bpms, acq_trigger_name));

    acqtrigvalue_start = 0;
    %acqtrigvalue_stop = 1;
    %acqtrigvalue_abort = 2;

    % Aqcuire
    for k=1:n
        % Acquire before acquisition trigger only to get timestamps
        cagetwvfh(handles_waveforms);
        tstamps1 = mcatime_ns(handles_waveforms.val);

        some_not_updated = true;
        try_idx = 1;
        while some_not_updated
            if try_idx > 10
                wvfs = [];
                break;
            end
            try_idx = try_idx + 1;
            for l=1:length(handles_acqtrigger)
                caputh(handles_acqtrigger(l), acqtrigvalue_start);
                pause(0.001); % To prevent overflowing RAM memory bandwidth when triggering ADC data acquisition on BPMs sharing a common RAM
            end
            pause(pause_period);

            wvfs(:,:,k) = cagetwvfh(handles_waveforms);
            tstamps2 = mcatime_ns(handles_waveforms.val);

            some_not_updated = any(all(tstamps1 == tstamps2, 2));
        end
    end

    % Close all MCA handles
    handles_acqtrigger = handles_acqtrigger(handles_acqtrigger ~= 0);
    if ~isempty(handles_acqtrigger)
        mcaclose(handles_acqtrigger(mcastate(handles_acqtrigger) == 1));
    end

    caclosewvf(handles_waveforms);

    r.wvfs = wvfs;
    r.pv_names = pv_names;
else
    r.wvfs = [];
    r.pv_names = [];
end


function tstamps = mcatime_ns(handles)

nwvfs = length(handles);
tstamps = zeros(nwvfs, 7);

for i=1:nwvfs
    try
        tstamps(i,:) = mca(60, handles(i));
    catch
    end
end
function [bpm_ok, raw, info] = bpm_checksw(bpms, params, active)

nbpms = length(bpms);

if nargin < 3 || isempty(active)
    active = true(nbpms, 1);
end

bpms_active = bpms(active);

sw_sts = caget(buildpvnames(bpms_active, 'SwMode-Sts'));

% Fill default return values
bpm_ok = nan(length(bpms),1);
info.test_name = 'Switching';
info.version = '1.1.0';
raw = struct;

% Turn switching off
caput(buildpvnames(bpms_active, 'SwMode-Sel'), 1);
if check_sw_setting(bpms_active, 1)
    % Retrieve BPMs' numerology and determine number of points for coherent sampling
    ntbt = caget(buildpvnames(bpms_active, 'INFOTBTRate-RB'));
    nsw = 2*caget(buildpvnames(bpms_active, 'SwDivClk-RB'));

    sw_tbt_factor = round(nsw./ntbt);
    nperiods = floor(1e5./sw_tbt_factor);
    npts = nperiods.*sw_tbt_factor;

    % Preapre for data acquistion
    wvf_names = {'GEN_AArrayData', 'GEN_CArrayData', 'GEN_BArrayData', 'GEN_DArrayData'};

    % Run data aqcuisitions with switching off
    data_nosw = tbt_acquire(bpms, active, wvf_names, npts);

    % Turn RFFE switching on (de-switching off)
    caput(buildpvnames(bpms_active, 'SwMode-Sel'), 0);
    if check_sw_setting(bpms_active, 0)
        % Run data aqcuisitions with RFFE switching on
        data_sw = tbt_acquire(bpms, active, wvf_names, npts);

        % Compare FFTs
        j = 1;
        for i=1:length(bpms)
            if active(i)
                if ~isempty(data_nosw{i}) && ~isempty(data_sw{i})
                    window = repmat(flattopwin(npts(j)), 1, size(data_nosw{i},2));
                    fft_wvfs_nosw = abs(fft(data_nosw{i}.*window));
                    fft_wvfs_sw = abs(fft(data_sw{i}.*window));
                    
                    % Calculate RMS value of all switching harmonics in
                    % both switching states
                    idx_swharm = nperiods(j)+1:nperiods(j):npts(j);
                    swharm_rms_nosw = sqrt(sum(fft_wvfs_nosw(idx_swharm, :).^2));
                    swharm_rms_sw = sqrt(sum(fft_wvfs_sw(idx_swharm, :).^2));
                    
                    bpm_ok(i) = double(all(swharm_rms_nosw./swharm_rms_sw < params.swharm_threshold));
                end
                j=j+1;

            end
        end

        caput(buildpvnames(bpms_active, 'SwMode-Sel'), sw_sts);

        raw.bpm = bpms;
        raw.params = params;
        raw.active = active;
        raw.data_nosw = data_nosw;
        raw.data_sw = data_sw;
        raw.ntbt = ntbt;
        raw.nsw = nsw;
    end
end

function data = tbt_acquire(bpms, active, wvf_names, npts)

j = 1;
for i=1:length(bpms)
    if active(i)
        data_ = bpm_acquire(bpms(i), wvf_names, 2, npts(j), 1, 0.5);
        data{i} = data_.wvfs;
        j=j+1;
    else
        data{i} = [];
    end
end

function success = check_sw_setting(bpms, sw_state)

for i=1:10
    if all(caget(buildpvnames(bpms, 'SwMode-Sts')) == sw_state)
        success = true;
        return;
    else
        pause(0.25);
    end
end

success = false;
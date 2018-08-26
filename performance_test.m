function performance_test(crate_number)

% Parameteres
gen_ip = '10.0.9.96';
Kxy = 10e6;
Pout_gen_default = 2;
Pout_gen = [13:-1:-21 -27]';
att_rffe = [31:-1:0 zeros(1,4)]';
n_res_fofb_acq = 5;
npts_res_fofb_acq = 1e5;
BW_fofb_f1 = 1e3;
BW_fofb_f2 = 9e3;
BW_fofb_f3 = 10e3;
npts_res_monit1_acq = 5e4;
BW_monit1_f1 = 0;
BW_monit1_f2 = 1;
bcd_range = [2 30];
target_bcd_res = 5;
max_acq_npts = 1e5;
npts_bcd_cycle = 25;
frf = 500e6;                         % RF frequency must be exactly 500 MHz
t_bcd_period = 1/(frf/516672)*npts_bcd_cycle;
npts_rawdata = 1e5;
raw_data_ch = 0:6;
sw_flag = {'sw', 'nosw'};

% Configure BPMs
[~,~,bpms] = bpm_config('/home/danielot/projects/bpm-cfg/foreign/bpm-tests/site_specific/sirius/config', crate_number);
pause(2);

% Synchronize Storage Ring and Booster BPMs switching
pv_amc0state = buildpvnames(sprintf('XX-%02dSL01:TI-EVR', crate_number), {'AMC0State-Sel'});
caput(pv_amc0state, 1);
pause(2);
caput(pv_amc0state, 0);

% Get sampling frequency information from BPMs
fofb_rate = caget(buildpvnames(bpms, 'INFOFOFBRate-RB'));
tbt_rate = caget(buildpvnames(bpms, 'INFOTBTRate-RB'));
monit1_rate = caget(buildpvnames(bpms, 'INFOMONITRate-RB'))/96; % FIXME: INFOMONIT1Rate-RB should be available on BPM IOC
Fs_adc = caget(buildpvnames(bpms, 'INFOClkFreq-RB'));
Fs_tbt = Fs_adc./tbt_rate;
Fs_fofb = Fs_adc./fofb_rate;
Fs_monit1 = Fs_adc./monit1_rate;

results.bpms = bpms;
results.Pout_gen = Pout_gen;
results.att_rffe = att_rffe;
results.raw_data_Fs = [Fs_adc' Fs_adc' Fs_tbt' Fs_fofb' Fs_tbt' Fs_fofb' Fs_monit1'];

% Connect to SMA100A generator (RF signal) and set modulation configuration
[~, rssma_handle] = rs_connect('tcpip', gen_ip);
rs_send_command(rssma_handle, sprintf('AM:SOUR %s', 'INT'));
rs_send_command(rssma_handle, sprintf('AM:INT:SOUR %s', 'LF2'));
rs_send_command(rssma_handle, sprintf('LFO2:SHAP %s', 'TRAP'));
rs_send_command(rssma_handle, sprintf('LFO2:SHAP:TRAP:RISE %0.9f s', t_bcd_period));
rs_send_command(rssma_handle, sprintf('LFO2:SHAP:TRAP:FALL %0.9f s', 0));
rs_send_command(rssma_handle, sprintf('LFO2:SHAP:TRAP:HIGH %0.9f s', 0));
rs_send_command(rssma_handle, sprintf('LFO2:SHAP:TRAP:LOW %0.9f s', 0));

for m=1:length(sw_flag)

    if strcmpi(sw_flag{m}, 'sw')
        caput(buildpvnames(bpms, 'SwMode-Sel'), 3);
        caput(buildpvnames(bpms, 'SwTagEn-Sel'), 1);
    elseif strcmpi(sw_flag{m}, 'nosw')
        caput(buildpvnames(bpms, 'SwMode-Sel'), 1);
        caput(buildpvnames(bpms, 'SwTagEn-Sel'), 0);
    end
    pause(5);

    xy_fofb = zeros(npts_res_fofb_acq*n_res_fofb_acq, 2*length(bpms));
    for i=1:length(Pout_gen)
        tic
        rs_send_command(rssma_handle, sprintf('MOD:STAT %s', 'OFF'));

        fprintf('\n');
        fprintf('Generator power = %0.2f dBm\n', Pout_gen(i));
        fprintf('RFFE attenuator = %0.1f dB\n', att_rffe(i));

        % Set RF power and RFFE attenuators simultaneously (make sure
        % attenuation will be increased before power is increased)
        if i == 1
            caput(buildpvnames(bpms, 'RFFEAtt-SP'), 31.5);
            pause(1);
            rs_send_command(rssma_handle, sprintf('POW %0.2f dBm', Pout_gen(i)));
            pause(1);
            caput(buildpvnames(bpms, 'RFFEAtt-SP'), att_rffe(i));
        elseif Pout_gen(i) > Pout_gen(i-1)
            caput(buildpvnames(bpms, 'RFFEAtt-SP'), att_rffe(i));
            pause(1);
            rs_send_command(rssma_handle, sprintf('POW %0.2f dBm', Pout_gen(i)));
        else
            rs_send_command(rssma_handle, sprintf('POW %0.2f dBm', Pout_gen(i)));
            pause(1);
            caput(buildpvnames(bpms, 'RFFEAtt-SP'), att_rffe(i));
        end

        % Resolution tests data acquisition
        for j=1:n_res_fofb_acq
            fprintf(['Acquiring at FOFB rate #' num2str(j)]);
            abcd = bpm_acquire(bpms, {'GEN_AArrayData' 'GEN_BArrayData' 'GEN_CArrayData' 'GEN_DArrayData'}, 3, npts_res_fofb_acq);
            fprintf(' Done!\n');
            xy_fofb((j-1)*npts_res_fofb_acq + (1:npts_res_fofb_acq), :) = calcpos(abcd.wvfs, Kxy, Kxy, 1, 'partial delta/sigma');
        end

        fprintf('Acquiring at Monit1 rate');
        abcd = bpm_acquire(bpms, {'GEN_AArrayData' 'GEN_BArrayData' 'GEN_CArrayData' 'GEN_DArrayData'}, 6, npts_res_monit1_acq);
        fprintf(' Done!\n');
        xy_monit1 = calcpos(abcd.wvfs, Kxy, Kxy, 1, 'partial delta/sigma');

        % Resolution calculations
        npts_fft = npts_res_monit1_acq/5;
        XY = psdrms(xy_monit1, Fs_monit1(j), BW_monit1_f1, BW_monit1_f2, rectwin(npts_fft), npts_fft/2, npts_fft, 'rms');
        results.res_rms_0p1hz_1hz(:, i) = XY(end,:);

        npts_fft = npts_res_fofb_acq;
        XY = psdrms(xy_fofb, Fs_fofb(j), BW_monit1_f2, BW_fofb_f1, rectwin(npts_fft), 0, npts_fft, 'rms');
        results.res_rms_1hz_1khz(:, i) = XY(end,:);

        npts_fft = npts_res_fofb_acq;
        XY = psdrms(xy_fofb, Fs_fofb(j), BW_monit1_f2, BW_fofb_f3, rectwin(npts_fft), 0, npts_fft, 'rms');
        results.res_rms_1hz_10khz(:, i) = XY(end,:);

        npts_fft = npts_res_fofb_acq;
        XY = psdrms(xy_fofb, Fs_fofb(j), BW_fofb_f2, BW_fofb_f3, rectwin(npts_fft), 0, npts_fft, 'sqrtpsd');
        results.res_nsd_at_10khz(:, i) = mean(XY);

        % Set RF generator AM modulation prior to BCD tests
        rs_send_command(rssma_handle, sprintf('AM:STAT %s', 'ON'));

        for k=1:length(bcd_range)
            rs_send_command(rssma_handle, sprintf('AM %0.2fPCT', bcd_range(k)/2));
            pause(1);
            
            n_bcd_cycles = ceil((mean(results.res_nsd_at_10khz(1:2:end,i).*sqrt(Fs_monit1'/2))/target_bcd_res)^2);            
            
            if n_bcd_cycles < 2
                n_bcd_cycles = 2;
            end
            
            npts_bcd_monit1_acq = npts_bcd_cycle*n_bcd_cycles;            
            nacq = ceil(npts_bcd_monit1_acq/max_acq_npts);
            
            if nacq > 1
                npts_bcd_monit1_acq = max_acq_npts;
            end

            % BCD test data acquisition
            fprintf('BCD %d%% test... ', bcd_range(k))
            abcd = [];
            for l = 1:nacq
                aux = bpm_acquire(bpms, {'GEN_AArrayData' 'GEN_BArrayData' 'GEN_CArrayData' 'GEN_DArrayData'}, 6, npts_bcd_monit1_acq);                
                % Align all periods to allow averaging
                for o = 1:4:size(aux.wvfs,2)
                    [~, idx] = max(aux.wvfs(1:npts_bcd_cycle, o));                    
                    aux.wvfs(:, o + (0:3)) = circshift(aux.wvfs(:, o + (0:3)), -idx-2);
                end                
                abcd = [abcd; aux.wvfs];
            end
            
            xy = calcpos(abcd, Kxy, Kxy, 1, 'partial delta/sigma');
            bcd = zeros(npts_bcd_cycle, size(xy,2));
            for j=1:size(xy,2)
                bcd(:,j) = mean(detrend(reshape(xy(:,j), npts_bcd_cycle,  size(xy,1)/npts_bcd_cycle),0),2);
            end
            results.bcd(:, i, k) = max(bcd)-min(bcd);
            fprintf(' Done!\n');
        end
        toc
    end

    rs_send_command(rssma_handle, sprintf('MOD:STAT %s', 'OFF'));
    pause(5);

    % Raw data acquisitions

    results.raw_data_ch = raw_data_ch;

    results.raw_data = zeros(npts_rawdata, length(bpms)*4, length(raw_data_ch));
    for i=1:length(raw_data_ch)
        abcd = bpm_acquire(bpms, {'GEN_AArrayData' 'GEN_BArrayData' 'GEN_CArrayData' 'GEN_DArrayData'}, raw_data_ch(i), 1e5);
        results.raw_data(:,:,i) = abcd.wvfs;
        pause(1);
    end

    save(sprintf('results_crate_%02d_%s_%s.mat', crate_number, sw_flag{m}, datestr(now, 'yyyy-mm-dd_HH-MM-SS')), 'results');
end

bpm_config('/home/danielot/projects/bpm-cfg/foreign/bpm-tests/site_specific/sirius/config', crate_number);
rs_send_command(rssma_handle, sprintf('POW %0.2f dBm', Pout_gen_default));

% Long-term drift test
pause(12*60*60 + 15*60);

% Test position dependence to general BPM resets
for i=1:10
    bpm_config('/home/danielot/projects/bpm-cfg/foreign/bpm-tests/site_specific/sirius/config', crate_number);
end
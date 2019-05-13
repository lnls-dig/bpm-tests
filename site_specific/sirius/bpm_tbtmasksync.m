function [tbttagdly, data_tbt, abs_data_adc] = bpm_tbtmasksync(bpms, npts_tbt, nruns_adc, ftrig)

nbpms = length(bpms);

if nargin < 2 || isempty(npts_tbt)
    npts_tbt = 1e3;
end
if nargin < 3 || isempty(nruns_adc)
    nruns_adc = 10;
end
if nargin < 4 || isempty(ftrig)
    ftrig = 2;
end

n = caget(buildpvnames(bpms, 'INFOTBTRate-RB'));
if any(n ~= n(1))
    error('All BPMs must have identical ''INFOTBTRate'' values.');
end
n = n(1);

tbttagdly_base = caget(buildpvnames(bpms, 'TbtTagDly-SP'));
acq_pause = max(1/ftrig + 1e-3, 1);

% Open PV connections for often-used PVs
hwvf = caopenwvf(buildpvnames(bpms, 'GEN_AArrayData'));
hacq = mcaopen(buildpvnames(bpms, 'ACQTriggerEvent-Sel'));
htbtdly = mcaopen(buildpvnames(bpms, 'TbtTagDly-SP'));

% Acquire masked TbT data
caput(buildpvnames(bpms, {'ACQBPMMode-Sel', ...
                          'ACQTrigger-Sel', ...
                          'ACQChannel-Sel', ...
                          'ACQSamplesPre-SP', ...
                          'ACQSamplesPost-SP', ...
                          'ACQTriggerRep-Sel', ...
                          'ACQShots-SP', ...
                          'TbtDataMaskEn-Sel', ...
                          'TbtDataMaskSamplesBeg-SP', ...
                          'TbtDataMaskSamplesEnd-SP'}), ...
                          repmat([0 1 2 0 npts_tbt 0 1 1 0 n-1], 1, nbpms));

caputh(hacq, 1);
pause(0.2);
caputh(hacq, 2);
pause(0.2);

data_tbt = zeros(n,nbpms);
for i=1:n
    caputh(htbtdly, rem(tbttagdly_base + i-1, n));
    caputh(hacq, 0);
    fprintf('Setting TbT tag delay offset = %d (from 0 to %d)...', i-1, n-1);
    pause(acq_pause);
    data_tbt(i,:) = mean(cagetwvfh(hwvf));
    fprintf(' Acquired TbT data!\n');
end

% Acquire ADC data (average over several acquisitions)
caput(buildpvnames(bpms, {'ACQChannel-Sel', ...
                          'ACQSamplesPre-SP', ...
                          'ACQSamplesPost-SP'}), ...
                          repmat([0 0 n], 1, nbpms));
pause(0.2);
data_adc = zeros(n,nbpms);
for i=1:nruns_adc
    caputh(hacq, 0);
    fprintf('ADC data acquisition: %d (from 1 to %d)...', i, nruns_adc);
    pause(acq_pause);
    fprintf(' Acquired ADC data!\n');
    data_adc = data_adc + cagetwvfh(hwvf);
end
data_adc = data_adc/nruns_adc;
abs_data_adc = abs(data_adc);

% Cross correlation
correl = ifft(fft(data_tbt).*conj(fft(abs_data_adc)),[],1,'symmetric'); %./repmat(sqrt(sum(data.^2).*sum(abs_data_adc.^2)), size(x,1), 1);
[~,tbttagdly] = max(correl);
tbttagdly = tbttagdly-1;

caputh(htbtdly, rem(tbttagdly_base + tbttagdly, n));

% Close all PV connections
caclosewvf(hwvf);
mcaclose(hacq);
mcaclose(htbtdly);
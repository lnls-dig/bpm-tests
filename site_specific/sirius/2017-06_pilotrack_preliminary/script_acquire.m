bpm_names = {};
for i=[17 21]
    bpm_names = [bpm_names, sprintf('SI-12-%d:DI-BPM',i)];
end
%bpm_names([11 12]) = [];

acqch = 0; % [0] adc   [1] adcswap  [2] tbt  [3] fofb
if acqch == 0
    npts = floor(1e5/65)*65;
elseif acqch == 1
    npts = floor(1e5/1950)*1950;
elseif acqch == 2
    npts = floor(1e5/5)*5;
else
    npts = 1e5;
end

data = acqnow(bpm_names, acqch, npts);

plot(squeeze(data(:,:,2)))
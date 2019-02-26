%%
crate_number = 17;

%frf = 499.65e6;
frf = 500e6;
clk_synth = frf/4*5;
ref_fraction = 5/36;
gen_ip = '10.0.9.96';

% [~, rssma_handle] = rs_connect('tcpip',gen_ip);
% rs_send_command(rssma_handle, sprintf('FREQ %d Hz', frf));
% rs_send_command(rssma_handle, sprintf('CSYN:FREQ %d Hz', clk_synth));

evr_name = sprintf('XX-%02dSL01:TI-EVR', crate_number);
pv_amc0state = buildpvnames(evr_name, {'AMC0State-Sel'});

% Set EVR (AFC timing) oscillator frequencies
caput(buildpvnames(evr_name, {'DevEnbl-Sel', 'AMC0State-Sel', 'AMC0Width-SP' 'AMC0Evt-SP' 'AMC0NrPulses-SP'}), [1 1 10 1 1]); pause(2);
caput(pv_amc0state, 0);
caput(buildpvnames(evr_name, {'RTMFreq-SP', 'AFCFreq-SP'}), [floor(frf/4) floor(frf*ref_fraction)]);
pause(2); 

%input('run EVG.py\n');

%%
bpm_config('/home/danielot/projects/bpm-cfg/foreign/bpm-tests/site_specific/sirius/config', crate_number);
% performance_test(crate_number);
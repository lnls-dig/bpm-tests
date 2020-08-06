function names = bpm_names(config_path, crate_number)
% names = BPM_NAMES(config_path, crate_number)
% Ex.: config_path = '/home/sirius/repos_temp/bpm-tests/site_specific/sirius/config/';

bpms = {};
bpmtypes = {};
for i=1:length(crate_number)
    filetext = readstrlines(fullfile(config_path, 'bpm', sprintf('names_crate%02d.cfg', crate_number(i))), '%s %s');
    bpms = [bpms; filetext{1}];
    bpmtypes = [bpmtypes; filetext{2}];
end

names.tim = bpms(strcmp(bpmtypes, 'tim'));
names.rfbpms.sr = bpms(strcmp(bpmtypes, 'rfbpm-sr'));
names.rfbpms.id = bpms(strcmp(bpmtypes, 'rfbpm-id'));
names.rfbpms.boo = bpms(strcmp(bpmtypes, 'rfbpm-boo'));
names.rfbpms.sp = bpms(strcmp(bpmtypes, 'rfbpm-sp'));
names.pbpms = bpms(strcmp(bpmtypes, 'pbpm'));

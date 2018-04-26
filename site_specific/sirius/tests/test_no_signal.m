#!/usr/bin/octave-cli -qf
arg_list = argv();
%arg_list = {'14'};

datestr_start = datestr(now, 'yyyy-mm-dd_HH-MM-SS');

bpm_config_path = 'site_specific/sirius/config';
test_results_path = 'test_results';
mkdir(test_results_path);

if length(arg_list) < 1
    fprintf('Must specify crate number.');
else
    warning off;
    addpath /usr/local/epics/extensions/src/mca/matlab
    addpath /usr/local/epics/extensions/lib/linux-x86_64
    initbpmtests;

    test_name = 'test_no_signal';
    log_filename = fullfile(test_results_path, sprintf('%s_%s.log', datestr_start, test_name));
    workspace_filename = fullfile(test_results_path, sprintf('%s_%s.mat', datestr_start, test_name));

    crate_number = str2double(arg_list{1});
    raw_results = exec_test_no_signal(bpm_config_path, crate_number, log_filename);
    analysis_results = analyze_test_no_signal(raw_results, log_filename);
    save(workspace_filename, 'raw_results', 'analysis_results');
end

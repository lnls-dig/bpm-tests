#!/usr/bin/octave -q
arg_list = argv();
%arg_list = {'14'};

datestr_start = datestr(now, 'yyyy-mm-dd_HH-MM-SS');

[script_path, test_name] = fileparts(mfilename('fullpath'));
cd(script_path);
cd('../../..');

bpm_config_path = 'site_specific/sirius/config';

if length(arg_list) < 1
    fprintf('Must specify crate number.\n');
elseif length(arg_list) < 2
    fprintf('Must specify a folder to store the test results.\n');
else
    warning off;
    initbpmtests;

    crate_number = str2double(arg_list{1});
    test_results_path = arg_list{2};

    if exist(test_results_path, 'dir')
        test_results_path = fullfile(test_results_path, sprintf('crate_%2d', crate_number));
        mkdir(test_results_path);
    else
        fprintf('The specified results folder does not exist.\n');
        return
    end

    log_filename = fullfile(test_results_path, sprintf('%s_%s.log', datestr_start, test_name));
    workspace_filename = fullfile(test_results_path, sprintf('%s_%s.mat', datestr_start, test_name));

    raw_results = exec_test_no_signal(bpm_config_path, crate_number, log_filename);
    analysis_results = analyze_test_no_signal(raw_results, log_filename);
    save(workspace_filename, 'raw_results', 'analysis_results');
end

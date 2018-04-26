function r = analyze_test_no_signal(config_path, test_result, log_filename)

if nargin < 3 || isempty(log_filename)
    fid_logfile = [];
else
    fid_logfile = fopen(log_filename, 'a');
end

fid = [1 fid_logfile];

data_3d = test_result.testdata.adc.wvfs;
names = test_result.testdata.adc.pv_names;

% Load test analysis parameters
config_filename = fullfile(config_path, 'test_no_signal', 'adc_data_limits.cfg');
analysis_config = readstrlines(config_filename, '%s %f');
for i=1:size(analysis_config{1},1)
    eval([analysis_config{1}{i} '=' num2str(analysis_config{2}(i)) ';']);
end

% Concatenate waveforms
data = [];
for j=1:size(data_3d,3)
    data = [data; data_3d(:,:,j)];
end

if ~isempty(data)
    logtext(fid, 'trace', 'Analyzing test results...');
    
    mean_ = mean(data);
    
    r.cond.freezed = names(sum(data) == 0);
    r.cond.std = names(std(data) > std_cmp);
    r.cond.mean = names((mean_ > abs(mean_cmp)) | (mean_ < -abs(mean_cmp)));
    r.cond.min = names(abs(min(data)-mean_) > d_mean_min_cmp);
    r.cond.max = names(abs(max(data)-mean_) > d_mean_max_cmp);
    
    if isempty(r.cond.freezed) && isempty(r.cond.std) && isempty(r.cond.mean) && isempty(r.cond.min) && isempty(r.cond.max)
        logtext(fid, 'info', 'Test results analyzed. All good!');
    else
        logtext(fid, 'error', 'Test results analyzed. Some waveforms violates specified limits.');
        for i=1:length(r.cond.freezed)
            logtext(fid, 'error', sprintf('All-zero values on waveform %s', r.cond.freezed{i}));
        end
        for i=1:length(r.cond.std)
            logtext(fid, 'error', sprintf('Violated standard deviation: %s', r.cond.std{i}));
        end
        for i=1:length(r.cond.mean)
            logtext(fid, 'error', sprintf('Violated mean value: %s', r.cond.mean{i}));
        end
        for i=1:length(r.cond.min)
            logtext(fid, 'error', sprintf('Violated distance between minimum and mean value: %s', r.cond.min{i}));
        end
        for i=1:length(r.cond.max)
            logtext(fid, 'error', sprintf('Violated distance between maximum and mean value: %s', r.cond.max{i}));
        end
    end
end

if ~isempty(fid_logfile)
    fclose(fid_logfile);
end

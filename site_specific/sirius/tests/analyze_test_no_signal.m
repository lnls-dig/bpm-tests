function r = analyze_test_no_signal(test_result, log_filename)

if nargin < 3 || isempty(log_filename)
    fid_logfile = [];
else
    fid_logfile = fopen(log_filename, 'a');
end

fid = [1 fid_logfile];

data_3d = test_result.testdata.adc.wvfs;
names = test_result.testdata.adc.pv_names;

std_cmp = 20;
mean_cmp = 50;
min_cmp = 100;
max_cmp = 100;

data = [];
for j=1:size(data_3d,3)
    data = [data; data_3d(:,:,j)];
end

if ~isempty(data)
    logtext(fid, 'trace', 'Analyzing test results...');
    
    mean_ = mean(data);
    
    r.cond.std = names(std(data) > std_cmp);
    r.cond.mean = names((mean_ > abs(mean_cmp)) | (mean_ < -abs(mean_cmp)));
    r.cond.min = names(abs(min(data)-mean_) > min_cmp);
    r.cond.max = names(abs(max(data)-mean_) > max_cmp);
    
    if isempty(r.cond.std) && isempty(r.cond.mean) && isempty(r.cond.min) && isempty(r.cond.max)
        logtext(fid, 'info', 'Test results analyzed. All good!');
    else
        logtext(fid, 'warning', 'Test results analyzed. Some waveforms not ok.');
        for i=1:length(r.cond.std)
            logtext(fid, 'warning', sprintf('Standard deviation: %s', r.cond.std{i}));
        end
        for i=1:length(r.cond.mean)
            logtext(fid, 'warning', sprintf('Mean value: %s', r.cond.mean{i}));
        end
        for i=1:length(r.cond.min)
            logtext(fid, 'warning', sprintf('Distance between minimum and mean value: %s', r.cond.min{i}));
        end
        for i=1:length(r.cond.max)
            logtext(fid, 'warning', sprintf('Distance between maximum and mean: %s', r.cond.max{i}));
        end
    end
end

if ~isempty(fid_logfile)
    fclose(fid_logfile);
end

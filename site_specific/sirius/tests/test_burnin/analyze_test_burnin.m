function [results_matrix, names] = analyze_test_burnin(varargin)

if ischar(varargin{1})
    results_path = varargin{1};

    dirinfo = dir(results_path);
    dirinfo = dirinfo(3:end);

    isdir_flag = [dirinfo.isdir];
    racks_path = {dirinfo.name};
    racks_path = racks_path(isdir_flag);

    for dir_idx = 1:length(racks_path)
        rack_path = fullfile(results_path, racks_path{dir_idx});
        dirinfo = dir(fullfile(rack_path, '*.mat'));
        tests_path = sort({dirinfo.name});
        for file_idx = 1:length(tests_path)
            filename = fullfile(rack_path, tests_path{file_idx});
            [~, names{dir_idx, file_idx}] = fileparts(filename);
            % TODO: use cell array of cell array instead of 2-D cell array
            results_matrix{dir_idx, file_idx} = load(filename, 'results');
        end
    end
else
    results_matrix = varargin{1};
    names = varargin{2};
end

for i=1:size(results_matrix,1)
    fprintf('\n\nCrate #%02d\n=========', i);
    for j=1:size(results_matrix,2)
        fprintf('\n\nTest #%02d\n=========', j);
        if ~isempty(results_matrix{i,j})
            close all
            analyze_result(results_matrix{i,j}.results, names{i,j})
            pause;
        end
    end
end

function analyze_result(results, name)

pass_fail_boolean = results.pass_fail == 1;

test_name_txt = sprintf('\n\nTest name: %s\n', name);

if isfield(results, 'test_names')
    test_names = reults.test_names;
else
    test_names = cellfun(@num2str, num2cell(1:size(pass_fail_boolean,2)), 'UniformOutput', 0);
end

disp_results(pass_fail_boolean, results.bpms, test_names, 1)

n = size(results.raw{7}.y,2);
for i=1:n/4
    if mean(mean(results.raw{7}.y(:,(i-1)*4 + (1:4)))) > 1e7
        data = results.raw{7}.y(:,(i-1)*4 + (1:4));
        figure;
        plot(results.raw{7}.t, (data./repmat(mean(data),size(data,1),1)-1)*100);
        legend(results.raw{7}.pv_names((i-1)*4 + (1:4)), 'Location', 'SouthWest');
        title(test_name_txt, 'Interpreter', 'none')
    end
end

amp_test_idx = 3;

for i=1:size(pass_fail_boolean,2)
    switch i
        case 4
            %Att./Cable
            if ~isempty(results.raw{i})
                worth_plotting = find(results.raw{4}.active & pass_fail_boolean(:,amp_test_idx) & ~pass_fail_boolean(:,i));

                if ~isempty(worth_plotting)
                figure;
                plot(results.raw{4}.diff_amp(worth_plotting, :)');
                legend(results.bpms(worth_plotting));
                end
            end
        case 6
            %Switching
            if ~isempty(results.raw{i})
                worth_plotting = find(results.raw{i}.active & pass_fail_boolean(:,amp_test_idx) & ~pass_fail_boolean(:,i));

                for k=1:length(worth_plotting)
                    figure;
                    for l=1:size(results.raw{i}.data_presw{k},2)
                        subplot(2,2,l);
                        semilogy(abs(fft(results.raw{i}.data_sw{worth_plotting(k)}(:, l))));
                        hold all;
                        if isfield(results.raw{i}, 'data_presw')
                            results.raw{i}.data_nosw = results.raw{i}.data_presw;
                            rmfield(results.raw{i}, 'data_presw');
                        end
                        semilogy(abs(fft(results.raw{i}.data_nosw{worth_plotting(k)}(:, l))));
                    end
                    subplot(2,2,1);
                    legend('Switching', 'Not switching');
                    title(results.bpms(worth_plotting(k)));
                end
            end
    end
end

function disp_results(result_matrix, row_names, col_names, fid)

if nargin < 4
    fid = 1;
end

row_len = max_len(row_names, 4);
col_len = max_len(col_names, 10);

nrows = length(row_names);
ncols = length(col_names);

div_line = repmat('-',1,4+row_len+(2+col_len)*ncols);

for i=1:length(fid)
    fprintf(fid(i), '\n')
    fprintf(fid(i), sprintf('| %%%ds |', row_len), '');
    for j=1:ncols
        fprintf(fid(i), sprintf('%%%ds |', col_len), col_names{j});
    end
    fprintf(fid(i), '\n')    
    fprintf(fid(i), div_line);
    fprintf(fid(i), '\n')
    for j=1:nrows
        if fid(i) == 1
            if ~all(result_matrix(j,:))
                clr = '[31m';
            else
                clr = '[32m';
            end
            pre = [char(27) clr];
            post = [char(27) '[0m'];
        else
            pre = '';
            post = '';
        end

        fprintf(fid(i), sprintf(['| ' pre '%%%ds' post ' |'], row_len), row_names{j});
        for k=1:ncols
            if result_matrix(j,k)
                result = 'pass';
                clr = '[32m';
            else
                result = 'fail';
                clr = '[31m';
            end
            if fid(i) == 1
                pre = [char(27) clr];
                post = [char(27) '[0m'];
            else
                pre = '';
                post = '';
            end
            fprintf(fid(i), [pre sprintf('%%%ds', col_len) post ' |'], result);
        end
%        fprintf(fid(i), '\n')
%        fprintf(fid(i), div_line);
        fprintf(fid(i), '\n')
    end
    fprintf(fid(i), '\n')
end

function len = max_len(name, min_len)

n = length(name);
len_array = zeros(n,1);
for i=1:n
    len_array(i) = length(name{i});
end
len = max(max(len_array)+1, min_len);

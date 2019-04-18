function [param, value, device] = bpm_readconfig(config_files)

param = {};
value = {};
device = {};
for i=1:length(config_files)
    aux = readstrlines(config_files{i}, '%s %s %s');
    
    for j=1:length(aux{2})
        aux{2}{j} = strrep(aux{2}{j} ,'_',' ');
        tmpstr = textscan(aux{2}{j}, '%f');
        aux{2}{j} = tmpstr{1};
    end    
    
    param = [param; aux{1}];
    value = [value; aux{2}];
    device = [device; aux{3}];
end
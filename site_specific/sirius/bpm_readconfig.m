function [param, value, device] = bpm_readconfig(config_files)

param = {};
value = [];
device = {};
for j=1:length(config_files)
    aux = readstrlines(config_files{j}, '%s %f %s');
    param = [param; aux{1}];
    value = [value; aux{2}];
    device = [device; aux{3}];
end
function [param, value, device] = bpm_readconfig(config_files)

config_file = config_files;
param = {};
value = [];
device = {};
for j=1:length(config_file)
    aux = readstrlines(config_file{j}, '%s %f %s');
    param = [param; aux{1}];
    value = [value; aux{2}];
    device = [device; aux{3}];
end
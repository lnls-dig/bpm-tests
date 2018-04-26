function [active_bpms, inactive_bpms, inactive_pvs_from_active_bpms] = bpm_applyconfig(bpm_names, config_files)

[param, value] = bpm_readconfig(config_files);

first_pv_names = buildpvnames(bpm_names, param(1));

bpm_status = caput(first_pv_names, value(1)) == 1; % '== 1' to overcome MCA limitation (return double instead of logical)
active_bpms = bpm_names(bpm_status);

pv_names = buildpvnames(active_bpms, param(2:end));
pv_status = [caput(pv_names, repmat(value(2:end), length(bpm_names(bpm_status)), 1))];

pv_names = [first_pv_names pv_names];
pv_status = [bpm_status(bpm_status) pv_status];

inactive_bpms = bpm_names(~bpm_status);
inactive_pvs_from_active_bpms = pv_names(~pv_status);
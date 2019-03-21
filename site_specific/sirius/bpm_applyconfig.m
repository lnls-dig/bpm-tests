function [bpm_ok, pv_ok] = bpm_applyconfig(bpm_names, config_files, probe_pv_property)

[param, value] = bpm_readconfig(config_files);

if  ~isempty(param)
    if nargin < 3 || isempty(probe_pv_property)
        probe_pv_property = param{1};
    end

    if ~isempty(bpm_names)
        bpm_ok = ~isnan(caget(buildpvnames(bpm_names, probe_pv_property)));
        bpm_names = bpm_names(bpm_ok);
        if ~isempty(bpm_names)
            pv_ok = caput(buildpvnames(bpm_names{1}, param), value) == 1;
            param = param(pv_ok);
            value = value(pv_ok);
            if length(bpm_names) > 1
                caput(buildpvnames(bpm_names(2:end), param), repmat(value, length(bpm_names)-1, 1));
            else
                pv_ok = [];
            end
        else
            pv_ok = [];
        end
    else
        bpm_ok = [];
        pv_ok = caput(param, value) == 1;
    end
else
    bpm_ok = [];
    pv_ok = [];
end
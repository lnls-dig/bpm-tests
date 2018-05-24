function bpm_ok = bpm_islocked(bpm_names)

bpm_ok = caget(buildpvnames(bpm_names, 'ADCAD9510PllStatus-Mon')) == 1;
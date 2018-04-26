function [locked, notlocked, inactive] = bpm_islocked(bpm_names)

lock_status = caget(buildpvnames(bpm_names, 'ADCAD9510PllStatus-Mon'));

inactive = bpm_names(isnan(lock_status));
locked = bpm_names(lock_status == 1);
notlocked = bpm_names(lock_status == 0);
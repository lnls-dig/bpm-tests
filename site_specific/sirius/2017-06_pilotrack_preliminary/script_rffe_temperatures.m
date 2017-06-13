[~,~,pvnames] = sirius_bpm_slot_mapping;

start_date = '2017-06-08 20:00:00';
duration = 24;

pvnames = buildpvnames(pvnames(4,11:23), {'RFFETempAC-RB', 'RFFETempBD-RB'});

timezone = -3;
eaaddr = 'http://10.0.4.69:11998';

% Get data
[data, t] = earetrieve(eaaddr, pvnames, start_date, duration, timezone);

% Plot data
eaplot(pvnames, data, t, timezone, 1);
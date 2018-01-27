[~,~,allslotnames] = sirius_bpm_slot_mapping;
bpmnames = allslotnames(4,11:23);
caput(buildpvnames(bpmnames, 'RFFEAtt'), [1 8.5 1 0.5 0.5 0.5 0 12.5 0.5 0.5 7.5 8 8] + 5.5);
   


[~,~,all_bpm_names] = sirius_bpm_slot_mapping;
bpm_names = all_bpm_names(4,11:23);

fid = fopen('pvnames','w+');
for i=1:length(bpm_names)
    fprintf(fid, '%s\n', bpm_names{i});
end
fclose(fid);
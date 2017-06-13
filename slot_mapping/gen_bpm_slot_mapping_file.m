function gen_bpm_slot_mapping_file(areas, devices)

ncrates = size(areas, 1);
nbpmslots = size(areas, 2);

fid = fopen('bpm-epics-ioc-slot-mapping', 'w');
for crate_number = 1:ncrates
    fprintf(fid, '# --- CRATE %d ---\n', crate_number);
    for bpmslot_number = 1:nbpmslots
        fprintf(fid, '\n# Crate %d - BPM slot %d - %s:%s\n', crate_number, bpmslot_number, areas{crate_number, bpmslot_number}, devices{crate_number, bpmslot_number});
        fprintf(fid, 'CRATE_%d_BPM_%d_PV_AREA_PREFIX=%s:\n', crate_number, bpmslot_number, areas{crate_number, bpmslot_number});
        fprintf(fid, 'CRATE_%d_BPM_%d_PV_DEVICE_PREFIX=%s:\n', crate_number, bpmslot_number, devices{crate_number, bpmslot_number});
    end
    fprintf(fid, '\n\n');
end
fclose(fid);
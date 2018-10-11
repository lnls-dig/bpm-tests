function tstamps = mcatime_ns(handles)

nwvfs = length(handles);
tstamps = zeros(nwvfs, 7);

for i=1:nwvfs
    try
        tstamps(i,:) = mca(60, handles(i));
    catch
    end
end
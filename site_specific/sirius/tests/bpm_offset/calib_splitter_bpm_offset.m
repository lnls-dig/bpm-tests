ip_archiver = 'http://10.0.38.46:11998';

period_s = 5;
npts = 10;
pv_suffixes = {'AmplA-Mon','AmplB-Mon','AmplC-Mon','AmplD-Mon','PosX-Mon','PosY-Mon'};

splitter = {'splitter_01', 'splitter_02'};

chron_order = false;

tstamporder = {};
calib = {};
for ispl=1:length(splitter)
    calib{ispl} = load(fullfile(splitter{ispl}, 'calib.txt'));
    calib{ispl} = calib{ispl}(:)';
    
    dirinfo = dir(fullfile(splitter{ispl}, '*.json'));
    filenames = {dirinfo.name};
    
    r = loadjson(fullfile(splitter{ispl}, filenames{1}));
    
    nfiles = length(filenames);
    natt = length(r.rffe_att);
    npvs = length(pv_suffixes);
    
    for ibpm=1:nfiles
        r = loadjson(fullfile(splitter{ispl}, filenames{ibpm}));
        rr{ispl}(ibpm) = r;
        tstamporder{ispl}(ibpm) = datenum(r.tstamp.init);
        fprintf('Loading timestamps file %s...\n', filenames{ibpm});
    end
end

if chron_order
    for ispl=1:length(splitter)
        [~,reorder] = sort(tstamporder{ispl});
        rr{ispl} = rr{ispl}(reorder);
    end
end

%%
data_direct_waveforms = {};
data_invert_waveforms = {};
for ispl=1:length(splitter)
    nfiles = length(rr{ispl});
    
    data_direct_waveforms{ispl} = nan(npts, nfiles, natt, npvs);
    data_invert_waveforms{ispl} = nan(npts, nfiles, natt, npvs);
    
    name = {};
    for ibpm=1:nfiles
        bpm_name = rr{ispl}(ibpm).bpm_name;
        name{ibpm} = bpm_name;
        
        if length(bpm_name) == 9
            bpm_name = [bpm_name(1:7) ':DI-BPM' bpm_name(8:9)];
        elseif length(bpm_name) == 7
            bpm_name = [bpm_name(1:7) ':DI-BPM'];
        end
        pvs = buildpvnames(bpm_name, pv_suffixes);
        fprintf('Retrieving data from archiver for BPM %s...\n', rr{ispl}(ibpm).bpm_name);
        period_total = (datenum(rr{ispl}(ibpm).tstamp.sw_inverted{end}) - datenum(rr{ispl}(ibpm).tstamp.sw_direct{1}))*24 + period_s/3600;
        
        [data_archiver, timestamps_archiver] = earetrieve(ip_archiver, pvs, rr{ispl}(ibpm).tstamp.sw_direct{1}, period_total, -3);
        
        for iatt=1:natt
            for ipv=1:npvs
                interval_direct = find(timestamps_archiver{ipv}-3/24 < datenum(rr{ispl}(ibpm).tstamp.sw_direct{iatt}) + period_s/3600/24);
                data_direct_waveforms{ispl}(:,ibpm,iatt,ipv) = data_archiver{ipv}(interval_direct(end+1-npts:end));
                interval_inverted = find(timestamps_archiver{ipv}-3/24 < datenum(rr{ispl}(ibpm).tstamp.sw_inverted{iatt}) + period_s/3600/24);
                data_invert_waveforms{ispl}(:,ibpm,iatt,ipv) = data_archiver{ipv}(interval_inverted(end+1-npts:end));
            end
        end
    end
    
end

%%
data_direct = {};
data_invert = {};
for ispl=1:length(data_direct_waveforms)
    nfiles = size(data_direct_waveforms{ispl}, 2);
    natt = size(data_direct_waveforms{ispl}, 3);
    npvs = size(data_direct_waveforms{ispl}, 4);
    data_direct{ispl} = zeros(nfiles, natt, npvs);
    data_invert{ispl} = zeros(nfiles, natt, npvs);
    for ibpm=1:size(data_direct_waveforms{ispl},2)
        fprintf('Averaging data (BPM %s)...\n', rr{ispl}(ibpm).bpm_name);
        for ipv=1:size(data_direct_waveforms{ispl},4)
            if ipv < 5
                data_direct{ispl}(ibpm,:,ipv) = exp(mean(log(squeeze(data_direct_waveforms{ispl}(:,ibpm,:,ipv)))));
                data_invert{ispl}(ibpm,:,ipv) = exp(mean(log(squeeze(data_invert_waveforms{ispl}(:,ibpm,:,ipv)))));
            else
                data_direct{ispl}(ibpm,:,ipv) = mean(squeeze(data_direct_waveforms{ispl}(:,ibpm,:,ipv)));
                data_invert{ispl}(ibpm,:,ipv) = mean(squeeze(data_invert_waveforms{ispl}(:,ibpm,:,ipv)));
            end
        end
    end
end

%%
ad = {}; bd = {}; cd = {}; dd = {};
ai = {}; bi = {}; ci = {}; di = {};
xd = {}; yd = {};
xi = {}; yi = {};
K = 8574318;
for ispl=1:length(data_direct)
    nfiles = size(data_direct{ispl}, 1);
    natt = size(data_direct{ispl}, 2);
    npvs = size(data_direct{ispl}, 3);
    
    fprintf('Calculating position offsets (splitter %d)...\n', ispl);
    
    data_amp_d = data_direct{ispl}(:,:,1:4);
    avg_amp = exp(mean(log(data_amp_d),3));
    avg_amp = repmat(avg_amp, 1, 1, 4, 1);
    data_amp_norm_d = data_amp_d./avg_amp;
    
    data_amp_i = data_invert{ispl}(:,:,1:4);
    avg_amp = exp(mean(log(data_amp_i),3));
    avg_amp = repmat(avg_amp, 1, 1, 4, 1);
    data_amp_norm_i = data_amp_i./avg_amp;
    
    ad{ispl} = squeeze(data_amp_norm_d(:,:,1))/calib{ispl}(1);
    bd{ispl} = squeeze(data_amp_norm_d(:,:,2))/calib{ispl}(2);
    cd{ispl} = squeeze(data_amp_norm_d(:,:,3))/calib{ispl}(3);
    dd{ispl} = squeeze(data_amp_norm_d(:,:,4))/calib{ispl}(4);
    
    ai{ispl} = squeeze(data_amp_norm_i(:,:,3))/calib{ispl}(1);
    bi{ispl} = squeeze(data_amp_norm_i(:,:,4))/calib{ispl}(2);
    ci{ispl} = squeeze(data_amp_norm_i(:,:,1))/calib{ispl}(3);
    di{ispl} = squeeze(data_amp_norm_i(:,:,2))/calib{ispl}(4);
    
    xy_splitter = calcpos(calib{ispl}, K, K, K, 'partial delta/sigma');
    
    data_xy_d = data_direct{ispl}(:,:,5:6);
    data_xy_i = data_invert{ispl}(:,:,5:6);
    
    xd{ispl} = squeeze(data_xy_d(:,:,1)) - xy_splitter(1);
    yd{ispl} = squeeze(data_xy_d(:,:,2)) - xy_splitter(2);
    
    xi{ispl} = -squeeze(data_xy_i(:,:,1)) - xy_splitter(1);
    yi{ispl} = -squeeze(data_xy_i(:,:,2)) - xy_splitter(2);
end

%%
text_xd = {}; text_xi = {};
text_yd = {}; text_yi = {};
ibpmmerge = 0;
for ispl=1:length(xd)
    for iatt=1:size(xd{ispl},2)
        att = rr{ispl}(1).rffe_att(iatt);
        for ibpm=1:size(xd{ispl},1)
            name = rr{ispl}(ibpm).bpm_name;
            if length(name) > 7
                name = [name(1:7) ':DI-BPM' name(8:9)];
                spacestr = '';
            else
                name = [name(1:7) ':DI-BPM'];
                spacestr = '  ';
            end
            text_xd{ibpm+ibpmmerge,iatt} = sprintf([name ':PosXOffset-SP' spacestr '    %10d    be'], round(xd{ispl}(ibpm,iatt)));
            text_xi{ibpm+ibpmmerge,iatt} = sprintf([name ':PosXOffset-SP' spacestr '    %10d    be'], round(xi{ispl}(ibpm,iatt)));
            text_yd{ibpm+ibpmmerge,iatt} = sprintf([name ':PosYOffset-SP' spacestr '    %10d    be'], round(yd{ispl}(ibpm,iatt)));
            text_yi{ibpm+ibpmmerge,iatt} = sprintf([name ':PosYOffset-SP' spacestr '    %10d    be'], round(yi{ispl}(ibpm,iatt)));
        end
    end
    ibpmmerge = size(text_yd,1);
end

%%
dirname = datestr(now, 'YYYY-mm-DD_HH-MM-SS');
mkdir(dirname);
for iatt=1:size(text_xd,2)
    text_d = [sort(text_xd(:,iatt)); sort(text_yd(:,iatt))];
    text_i = [sort(text_xi(:,iatt)); sort(text_yi(:,iatt))];
    
    att = rr{ispl}(1).rffe_att(iatt);
    fid_d = fopen(sprintf('%s/posoffset_swdirect_att%ddB.txt', dirname, att), 'w+');
    fid_i = fopen(sprintf('%s/posoffset_swinverted_att%ddB.txt', dirname, att), 'w+');
    for ibpm=1:size(text_d,1)
        if ibpm>1
            fprintf(fid_d, '\n');
            fprintf(fid_i, '\n');
        end
        fprintf(fid_d, text_d{ibpm});
        fprintf(fid_i, text_i{ibpm});
    end
    fclose(fid_d);
    fclose(fid_i);
end
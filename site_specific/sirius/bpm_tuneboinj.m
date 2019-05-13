function bpm_tuneboinj(wvfs, turns_analysis, nturns_fft, inj_analysis)

if nargin < 2 || isempty(turns_analysis)
    turns_analysis = 1:size(wvfs, 1);
end

if nargin < 3 || isempty(nturns_fft)
    nturns_fft = 10;
end

if nargin < 4 || isempty(inj_analysis)
    inj_analysis = 1:size(wvfs, 3);
end

% Crop data
wvfs = wvfs(turns_analysis,:,inj_analysis);
nturns = size(wvfs,1);
nbpms = size(wvfs,2)/3;
ninj = size(wvfs,3);
nfftarray = nturns - nturns_fft;

% Select position data and convert to [mm]
x = wvfs(:,1:3:end,:)/1e6;
y = wvfs(:,2:3:end,:)/1e6;

% Select Sum data
sum = wvfs(:,3:3:end,:);

% Sort BPMs to follow beam order (first BO-02U, BO-03U ... BO-50U, BO-01U)
x = x(:,[2:end 1],:);
y = y(:,[2:end 1],:);
sum = sum(:,[2:end 1],:);

% Beam trajectroy along several turns
xtraj = reshape(permute(x,[3 2 1]), ninj, nturns*nbpms)';
ytraj = reshape(permute(y,[3 2 1]), ninj, nturns*nbpms)';
sumtraj = reshape(permute(sum,[3 2 1]), ninj, nturns*nbpms)';

% Segment data into sequential sets of turns
xtrajsegs = reshape(xtraj, nbpms, nturns, ninj);
ytrajsegs = reshape(ytraj, nbpms, nturns, ninj);

xtrajsegs_fft = zeros(nturns_fft*nbpms, nfftarray, ninj);
ytrajsegs_fft = zeros(nturns_fft*nbpms, nfftarray, ninj);
xorbit = zeros(nbpms, nfftarray, ninj);
yorbit = zeros(nbpms, nfftarray, ninj);
for i=1:nfftarray
    % Remove mean trajectory (orbit) from each segment
    xtrajsegs_orbit = xtrajsegs(:, i:i+nturns_fft-1, :);
    ytrajsegs_orbit = ytrajsegs(:, i:i+nturns_fft-1, :);
    
    xorbit(:,i,:) = mean(xtrajsegs_orbit, 2);
    yorbit(:,i,:) = mean(ytrajsegs_orbit, 2);
    
    xtrajsegs_noorbit = xtrajsegs_orbit - repmat(xorbit(:,i,:), 1, nturns_fft, 1);
    ytrajsegs_noorbit = ytrajsegs_orbit - repmat(yorbit(:,i,:), 1, nturns_fft, 1);
    
    xtrajsegs_dd(:,i,:) = reshape(xtrajsegs_orbit, nturns_fft*nbpms, ninj);
    ytrajsegs_dd(:,i,:) = reshape(ytrajsegs_orbit, nturns_fft*nbpms, ninj);
    
    xtrajsegs_fft(:,i,:) = reshape(xtrajsegs_noorbit, nturns_fft*nbpms, ninj);
    ytrajsegs_fft(:,i,:) = reshape(ytrajsegs_noorbit, nturns_fft*nbpms, ninj);
end

% Compute FFT
fft_x = zeros(ceil((nturns_fft*nbpms+1)/2), nfftarray, ninj);
fft_y = zeros(ceil((nturns_fft*nbpms+1)/2), nfftarray, ninj);
for i=1:ninj
    [fft_x(:,:,i), f] = fourierseries(xtrajsegs_fft(:,:,i), nbpms);
    fft_y(:,:,i) = fourierseries(ytrajsegs_fft(:,:,i), nbpms);
end

for i=1:ninj
    for j=1:nbpms
        [fft_x_perbpm(:,:,i,j), f_perbpm] = fourierseries(xtrajsegs_dd(j:nbpms:end,:,i), 1);
        fft_y_perbpm(:,:,i,j) = fourierseries(ytrajsegs_dd(j:nbpms:end,:,i), 1);
    end
end

% Plot data
t = 1:nfftarray;
if ninj > 10
    warning('Plotting only first 10 injections');
end
for i=1:min(ninj, 10)
    figure;
    h = surf(t, f, fft_x(:,:,i));
    set(h, 'EdgeAlpha', 0.3);
    title(sprintf('Injection #%d - X position', inj_analysis(i)));
    xlabel('Turn');
    ylabel('Tune X');
    zlabel('Position [mm]');
    view(0,90);
    
    figure;
    h = surf(t, f, fft_y(:,:,i));
    set(h, 'EdgeAlpha', 0.3);
    title(sprintf('Injection #%d - Y position', inj_analysis(i)));
    xlabel('Turn');
    ylabel('Tune Y');
    zlabel('Position [mm]');
    view(0,90);
    
    figure;
    plot((0:nturns*nbpms-1)/nbpms, sumtraj(:,i));
    title(sprintf('Injection #%d - Sum', inj_analysis(i)));
    xlabel('Turn');
    ylabel('Sum');    
end
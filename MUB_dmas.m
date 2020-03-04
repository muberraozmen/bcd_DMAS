function [Image_3D,Image_2D,signals_aligned,baseline_aligned] = MUB_dmas(signals,baseline,settings)
% This function implements DMAS algorithm to generate an image
%
% INPUTS : 
% signals: the tumour signals
% baseline: the baseline signals
% settings = a struct that contains the settings (parameters)

% OUTPUTS: 
% Image_3D  : 3d matrix of intensities
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Required settings parameters
% settings.d_sf : distances to each voxel [no. channels x no. voxels]
% settings.v_estimated : estimated velocity in breast [scalar]
% settings.dt : time step (seconds per sample) [scalar]
% settings.voxels : location of each voxel [no. voxels x 3]
% settings.grid_lower : lower boundary of grid for imaging
% settings.image_size : size of 3D image to generate [1 x 3]

% Align the signals
signals_aligned = signals;
baseline_aligned = baseline;
settings.maxLag = 1000;
settings.align = 1;
if settings.align
    for k = 1:settings.nSensor
        for m = 1:settings.nSensor
            if k~=m
                [x,y,D] = alignsignals(squeeze(signals(k,m,:)), squeeze(baseline(k,m,:)), 1000, 'truncate');
                signals_aligned(k,m,:) = x;
                baseline_aligned(k,m,:) = y;
            end
        end
    end
end

% Calculate the tumour signal (signals-baseline)
% Reshape (permute + reshape) it so that it is a 2-d matrix with dimensions [nSample,nSensor^2] 
signals_calibrated = signals_aligned-baseline_aligned;
signals_calibrated = permute(signals_calibrated,[3,2,1]);
data = reshape(signals_calibrated,settings.nSample,settings.nSensor*settings.nSensor);

% Initialize the image to NaNs
Image_3D = NaN(settings.image_size);

voxel_num = size(settings.voxels,1);
% Generate one 2D image for each z-value - stored as a vector
Image_2D = NaN(1,voxel_num);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate delays for each voxel-channel pair
tau_ir = round(real((settings.d_sf/settings.v_estimated)/settings.dt));

n_a = max(tau_ir(:));% Largest delay across all channels and locations.
n_ir = n_a - tau_ir; 

% Calculate a treshold on round trip distances 
d_treshold = prctile(settings.d_sf,80,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate the 2D image
nChannels = size(data,2);

viy = 0:settings.nSample:settings.nSample*(nChannels-1);

tic
%parpool(6);
%gcp(); % Reinstate this for parallel computation
for voxel_ix = 1:voxel_num % iterations through focal points
% for voxel_ix = 1:voxel_num % iterations through focal points
    
    % Indicate percent complete
    if rem(voxel_ix,1000)==0
        disp(num2str(round(100*voxel_ix/voxel_num)));
    end
    
    % Generate indexing matrix to align signals
    vix = [1:settings.nSample]';
    vix = bsxfun(@minus,vix,n_ir(:,voxel_ix)');
    vix(vix<=0) = 1;
    vix = bsxfun(@plus,viy,vix);

    % Delays signals by appropriate amount
    signals_focused = data(vix);

    % Omit signals based on distance
    selected_antenna_pairs = settings.d_sf(:,voxel_ix) <= d_treshold(voxel_ix);
    signals_focused = signals_focused(:,selected_antenna_pairs);
            
    % Apply DMAS calculation and populate the image
    beamformer_output = (sum(signals_focused,2).^2 - sum(signals_focused.^2,2))/nChannels^2;
    Ir = mean(abs(beamformer_output).^2);
    Image_2D(voxel_ix) = Ir;
end
%delete(gcp('nocreate'))
toc

% Reconstruct the 3D image based on the 2D intensity matrix Image_2D
for voxel_ix = 1:voxel_num
    voxel_coordinates = round((settings.voxels(voxel_ix,:) - settings.grid_lower-settings.voxel_width/2)/settings.voxel_width + 1);
    Image_3D(voxel_coordinates(1),voxel_coordinates(2),voxel_coordinates(3)) = Image_2D(voxel_ix);
end



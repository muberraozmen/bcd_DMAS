function settings = MARK_configure(settings_file,stored_settings,generate_settings)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Populate the settings structure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Focal points setup
% Required input parameters
% settings.d_sf : distances to each voxel [no. channels x no. voxels]  
% settings.v_estimated : estimated velocity in breast [scalar]
% settings.dt : time step (seconds per sample) [scalar]                
% settings.voxels : location of each voxel [no. voxels x 3]            
% settings.grid_lower : lower boundary of grid for imaging             
% settings.image_size : size of 3D image to generate [1 x 3]           
% settings.breast_dimensions : dimensions of the breast (z,x,y)       

% load or generate the imaging algorithm settings
% When generate_settings is set to true, the imaging parameter settings
% is re-generated. This can be time-consuming - primarily calculating the
% distances from the antennas to the voxels


if generate_settings

    settings = feval(settings_file);

    %%  Velocity estimate
    C_0 = 2.997924580003452e+08;

    settings.v_estimated   = real(C_0./sqrt(settings.permittivity.*settings.permeability));
    
    % Create the voxel locations and calculate the image size
    % settings.voxels: an n x 3 matrix containing voxel coordinates
    % settings.image_size: a 1 x 3 vector indicating the number of voxels in each axis.
    [settings.voxels, settings.image_size] = MARK_createFocalPts(settings);
           
    % Calculate the round trip distance between the sensors and the voxels
    % First calculate the distance from each antenna to each voxel (D)
    X = settings.antenna_locations;
    Y = settings.voxels;
    XX = sum(X.*X,2);
    YY = sum(Y'.*Y',1);
   
    D = sqrt(XX(:,ones(1,size(Y,1))) + YY(ones(1,size(X,1)),:) - 2*X*Y');
    
    % Now calculate the round-trip distances for each antenna pair
    % Subtract twice the tumor-radius to model a tumour centred at the voxel
    % location
    vc = repmat(D,settings.nSensor,1);
    vd = kron(D,ones(settings.nSensor,1));
    
    settings.d_sf = vc + vd;
    for i= 1:settings.nSensor
       settings.d_sf(((i-1)*16)+i,:) = zeros(size(settings.d_sf(1,:)));
    end
    save(stored_settings,'settings');
    
else
    load(stored_settings);
end



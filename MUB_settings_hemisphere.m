function settings = MUB_settings_hemisphere()

% Settings for Hemisphere - Phantom 1 - Tumour 13
% Manually prepeared based on MARK_settings.m

% Number of sensors
settings.nSensor = 16;

% Boundaries of the grid (z,x,y)
settings.grid_lower = [0 -7e-2 -7e-2];
settings.grid_upper = [7e-2, 7e-2, 7e-2];

% Width of each voxel
settings.voxel_width = 2e-3;

% Dimensions of the breast (the radius of the region for imaging)
settings.breast_dimensions = [0.07,0.07,0.07];

% Time step and number of samples (before and after downsampling and
% windowing)
settings.dt = 5e-12;
settings.nSample_original = 4096;
settings.nSample = 1000;

% Indicator of any channels or antennas to exclude
settings.excluded_antennas = [];
settings.excluded_channels = [];

% Set the permittivity and permeability to estimated average values
settings.permittivity = 8;
settings.permeability = 1;
    
% If there is a tumour size to test for include non-zero radius for delay calculations [OPTIONAL]    
settings.tumour_radius = 10;

% If there is a known tumour (phantom data)
settings.tumour_location = [0.0329,-0.0267,-0.0072];

settings.box_dimensions = [0.03,0.03,0.03];
% Box_dimensions should be expressed in m 
% Example a 1 cm box is [0.01,0.01,0.01]
% This will extend 5mm in each direction from the tumour location

%%%%%%%%%%% ARRAY CONFIGURATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%
ant_r = 70; 
ant_theta = deg2rad([15 15 15 15 15 15 15 15 45 45 45 45 45 45 45 45]);
ant_phi = deg2rad([-15 15 75 105 165 -165 -105 -75 -15 15 75 105 165 -165 -105 -75]);

antenna_locations = zeros(16,3);
for i = 1:16
   [x, y, z] = sph2cart(ant_phi(i),ant_theta(i),ant_r); 
   antenna_locations(i,:) = [z x y];
end
        
settings.antenna_locations = antenna_locations * 1e-3;




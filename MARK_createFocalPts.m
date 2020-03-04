function [voxels, image_size] =  MARK_createFocalPts(settings)
%% Create focal points by scanning through the breast
%% Input:
% settings: a structure that holds the breast properties.
%% Output:
% voxels: an n x 3 matrix containing voxel coordinates
% image_size: a 1 x 3 vector indicating the number of voxels in each axis.

% The 3-D numerical breast phantom, x^2/a^2 + y^2/b^2 + z^2/c^2 = 1,
% where z>0 is the depth direction. Unit is cm.

a = settings.breast_dimensions(1);
b = settings.breast_dimensions(2);
c = settings.breast_dimensions(3);

dx = settings.voxel_width;

z_pos = settings.grid_lower(1)+dx/2:dx:settings.grid_upper(1)-dx/2;
x_pos = settings.grid_lower(2)+dx/2:dx:settings.grid_upper(2)-dx/2;
y_pos = settings.grid_lower(3)+dx/2:dx:settings.grid_upper(3)-dx/2;

image_size = [length(z_pos), length(x_pos), length(y_pos)];

[Z, X, Y] = meshgrid(z_pos,x_pos,y_pos);

square_sum = Z.^2/a^2 + X.^2/b^2 + Y.^2/c^2;
square_sum_less_than_0 = find(square_sum<1);

voxels(:,1) = Z(square_sum_less_than_0);
voxels(:,2) = X(square_sum_less_than_0);
voxels(:,3) = Y(square_sum_less_than_0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%
%%%%%
% The code below is commented but not deleted because I don't know why there needs
% to be this adjustment for the phantom and clinical data


%switch settings.dataset_name
%   case {'phantom_2015','clinical_2015'}
%        square_sum = Z.^2/a^2 + (X-.09).^2/b^2 + Y.^2/c^2;
%    otherwise
%        square_sum = Z.^2/a^2 + X.^2/b^2 + Y.^2/c^2;
%end



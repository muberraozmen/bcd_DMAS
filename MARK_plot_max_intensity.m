function slice_z_pos = MARK_plot_max_intensity(Image3D,settings)
% Plot a 2d image of the maximum intensity slice
% 
% Inputs: Image3D: the 3d image
% settings: parameter values

% identify the coordinates of the voxel with the peak intensity
[max_intensity, max_ix] = max(Image3D(:));
[z_max, x_max, y_max] = ind2sub(size(Image3D),max_ix)

% Calculate the z position
slice_z_pos = z_max*settings.voxel_width*100;

% Extract the slice
data = squeeze(Image3D(z_max,:,:));

% Call MARK_plot_slice to plot the slice
MARK_plot_slice(data,slice_z_pos,settings);


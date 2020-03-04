 function [SCR,SMR,z_max, y_max, x_max, loc_error, max_int_box] = MARK_calc_errors(Image3D,settings)
% Calculate the signal-to-clutter ratio and the signal-to-mean ratio
% SCR: the ratio between the maximum value in a box around the true tumour
% location and the maximum value outside the box
%
% SMR: the ratio between the maximum value in a box around the true tumour
% location and the mean intensity of the image
%
% Inputs: Image3D: 3-dimensional image
% settings: the parameter values (including tumour_location and
% box_dimensions)
for i=1:35
    dummy_image_1(i,:,:) = squeeze(Image3D(i,:,:));
end
dummy_image_1(isnan(dummy_image_1))=0;

[max_intensity, max_ix] = max(dummy_image_1,[],'all','linear');
[z_max, y_max, x_max] = ind2sub(size(dummy_image_1),max_ix);

% Express the tumour location in terms of voxels
tum_loc = round((settings.tumour_location-settings.grid_lower)/settings.voxel_width);

% Calculate box dimensions in terms of voxels
dist = round(settings.box_dimensions/settings.voxel_width/2);

% Calculate boundaries of the box
min_box = max(tum_loc-dist,1);
max_box = tum_loc+dist;
max_box = min(max_box,size(Image3D));

% Extract the region of the image corresponding to the box and set any nan
% values to zero
BoxArndTumr = dummy_image_1(min_box(1):max_box(1),min_box(3):max_box(3),min_box(2):max_box(2));
BoxArndTumr(isnan(BoxArndTumr))=0;

% Construct a dummy image that zeros the values in the box
% Set any nan values to zero
dummy_image = dummy_image_1;
dummy_image(isnan(dummy_image))=0;
dummy_image(min_box(1):max_box(1),min_box(3):max_box(3),min_box(2):max_box(2))=0;

SCR = 20*log10(max(BoxArndTumr,[],'all','omitnan')/max(dummy_image,[],'all','omitnan'));
SMR = 20*log10(max(BoxArndTumr,[],'all','omitnan')/nanmean(dummy_image_1,'all'));
loc_error = norm([(z_max*2)-tum_loc(1)*2, ((y_max-35)*2)-(tum_loc(3)-35)*2, ((x_max-35)*2)-(tum_loc(2)-35)*2]);
max_int_box=max(BoxArndTumr,[],'all','omitnan');

['SCR=' num2str(SCR) 'dB']
['SMR=' num2str(SMR) 'dB']
['loc_error=' num2str(loc_error) 'mm']
['z_max=' num2str(z_max)]
['x_max=' num2str(x_max)]
['y_max=' num2str(y_max)]
['max_intensity=' num2str(max_intensity)]
['max_int_box=' num2str(max_int_box)]
tum_loc = round((settings.tumour_location-settings.grid_lower)/settings.voxel_width);
['tum_loc=' num2str(tum_loc)]



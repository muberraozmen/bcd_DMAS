%% Load data

% Parameters
nSamples = 1000;
start_point = 1200; 
f_s_data = 160e9;
f_pass = [1.7e9 4e9];

% Data folders
DATA_DIR = '/Users/mob/Documents/MATLAB/bcd_data/Hemisphere Experiment A/Initialization_Exp/';
folder = 'Baseline1/';
[baseline_raw,~,~]= MARK_load_data(DATA_DIR, folder, nSamples, start_point);
folder = 'Tumor1/';
[signals_raw,~,~]= MARK_load_data(DATA_DIR, folder, nSamples,start_point);

baseline = baseline_raw;
signals = signals_raw;

%% Settings

% Choose whether to generate or load settings
ps.generate_settings=1; 
ps.settings_file = 'MUB_settings_hemisphere';  % m-file to populate settings
ps.stored_settings = 'MUB_settings_hemisphere.mat'; % mat_file with previously calculated settings

% Initialize local variables
settings = MARK_configure(ps.settings_file, ps.stored_settings, ps.generate_settings);


%% Imaging (original)

% Calculate the 3d image
[Image3D_dmas,data,signals_aligned,baseline_aligned] = MARK_dmas(signals,baseline,settings);

% Normalize the intensity to the maximum in 3D volume
[max_intensity, max_ix] = max(Image3D_dmas(:));
Image3D_norm = 1/max_intensity*Image3D_dmas;

% Plot the maximum intensity slice
figure;
slice_z_pos = MARK_plot_max_intensity(Image3D_norm,settings);
saveas(gcf, 'original_max_intensity.png')
close all

% Calculate the signal-to-clutter and signal-to-mean ratios
[SCR,SMR,z_max, y_max, x_max, loc_error, max_int_box] = MARK_calc_errors(Image3D_dmas,settings);

% Create a gif of slices
filename = 'original_slices.gif';
for i = 1:1:35
mg = i;
figure(i)
MARK_plot_slice(squeeze(Image3D_norm(mg,:,:)),mg*0.2,settings)

% Capture the plot as an image 
drawnow
frame = getframe(i);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256); 
if i == 1 
    imwrite(imind,cm,filename,'gif','Loopcount',inf,'DelayTime',0.2); 
else 
    imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.2); 
end

end
close all


%% Imaging (modified)

% Calculate the 3d image
[Image3D_dmas,data,signals_aligned,baseline_aligned] = MUB_dmas(signals,baseline,settings);

% Normalize the intensity to the maximum in 3D volume
[max_intensity, max_ix] = max(Image3D_dmas(:));
Image3D_norm = 1/max_intensity*Image3D_dmas;

% Plot the maximum intensity slice
figure;
slice_z_pos = MARK_plot_max_intensity(Image3D_norm,settings);
saveas(gcf, 'modified_max_intensity.png')
close all

% Calculate the signal-to-clutter and signal-to-mean ratios
[SCR,SMR,z_max, y_max, x_max, loc_error, max_int_box] = MARK_calc_errors(Image3D_dmas,settings);

% Create a gif of slices
filename = 'modified_slices.gif';
for i = 1:1:35
mg = i;
figure(i)
MARK_plot_slice(squeeze(Image3D_norm(mg,:,:)),mg*0.2,settings)

% Capture the plot as an image 
drawnow
frame = getframe(i);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256); 
if i == 1 
    imwrite(imind,cm,filename,'gif','Loopcount',inf,'DelayTime',0.2); 
else 
    imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.2); 
end

end
close all






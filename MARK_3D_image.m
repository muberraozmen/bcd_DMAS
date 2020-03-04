function[] = MARK_3D_image(x,erode_layers)
% Plot a 3d breast image
%
% Each voxel is plotted as a colored cube, such that the entire image forms
% a 3d brain.
%
% Usage: MARK_3D_image(x,erode_layers)
%
% INPUTS:
%            x: a 3d matrix (tensor) of voxel activations
%      
% erode_layers: optional argument specifying how many layers to make much
%               more transparent.  this allows patterns beneath the surface
%               of the brain to be more-easily seen.
%
% OUTPUTS: [none]
%
% Adapted from plot_brain3d.m by Jeremy Manning
%  AUTHOR: Jeremy R. Manning
% CONTACT: manning3@princeton.edu


if ~exist('erode_layers','var')
    erode_layers = 0;
end

se = strel('arbitrary',ones([3 3 3]));
mask = ~isnan(x);
for i = 1:erode_layers
    mask = imerode(mask,se);
end

outer = x;
outer(mask) = nan;
inner = x;
inner(~mask) = nan;

hold on;
h1 = PATCH_3Darray(inner,'col');
if iscell(h1)
    for i = 1:length(h1)
        set(h1{i},'FaceAlpha',0.25);%,'EdgeColor','none');
    end
else
    set(h1,'FaceAlpha',0.25);
end

if erode_layers > 0
    h2 = PATCH_3Darray(outer,'col');
    if iscell(h2)
        for i = 1:length(h2)
            set(h2{i},'FaceAlpha',0.1,'EdgeColor','none');
        end
    else
        set(h2,'FaceAlpha',0.1,'EdgeColor','none');
    end
end

axis square;
axis off;

set(gca,'CameraPosition',[-239.1516 -192.6841 256.3707]);
function[] = MARK_plot_slice(data,slice_z_pos,settings)
% Generate an image intensity plot for the 2d image in data
%
%

% Set the font size for the figure
fontSize = 24;

g_low = settings.grid_lower(2:3)*100;
g_high = settings.grid_upper(2:3)*100;

% Calculate dimensions of the image and pad with a row and a colum of NaNs.
% Use pcolor to generate a 2d image
[nr,nc] = size(data);
figure
% caxis([0 1])
pcolor(linspace(g_low(1),g_high(1),nr+1),linspace(g_low(2),g_high(2),nc+1),[data nan(nr,1); nan(1,nc+1)]);

caxis([0 1]);

% Set the shading to flat and reverse the y-axis so that it runs in the
% intuitive direction (bottom-to-top)
shading flat;
% set(gca, 'ydir', 'reverse');

% 
axis([g_low(1)-1 g_high(1)+1 g_low(2)-1 g_high(2)+1]);
xlabel('X(cm)','FontSize',fontSize);
ylabel('Y(cm)','FontSize',fontSize);
colorbar
colorbar('Ticks', [0:0.2:1]);
colormap(jet);

set(gcf,'color','w');
set(gca,'FontSize',fontSize);
title(['Image at z = ',num2str(slice_z_pos),' cm']);


if nargin==3
    tum_loc = settings.tumour_location;
    hold on
    v = plot(tum_loc(2)*100,tum_loc(3)*100,'x');
    set(v,'LineWidth',4);
    set(v,'MarkerSize',12);
    set(v,'color','r');
end
% saveas(v,'Image_at_z_' num2str(slice_z_pos) '_cm.png','png');

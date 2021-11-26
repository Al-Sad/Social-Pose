% Copyright (c) 2021 Mohammad Fathi Al-Sa'd
% 
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the "Software"),
% to deal in the Software without restriction, including without limitation
% the rights to use, copy, modify, merge, publish, distribute, sublicense,
% and/or sell copies of the Software, and to permit persons to whom the
% Software is furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
% THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
% FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
% DEALINGS IN THE SOFTWARE.
%
% Email: mohammad.al-sad@tuni.fi, alsad.mohamed@gmail.com
%
% The following reference should be cited whenever this script is used:
% M. Al-Sa'd, S. Kiranyaz, I. Ahmad, C. Sundell, M. Vakkuri, and M. Gabbouj,
% "A social distance estimation and crowd monitoring system for surveillance
% cameras", TBA, (2021).
%
% Last Modification: 12-November-2021
%
% Description:
% This demo script produces the results that are depicted in Figs. 4c, 4d,
% 4g, and 4h of the paper. It generates the estimated inter-personal
% distances and instantaneous occupancy/crowd density maps in the image
% -pixel and real-world coordinates. Additionally, it demonstrates the
% detected social distance violations in both domains.

%% Initialization
clear; close all; clc;
addpath(genpath('Functions'));

%% Parameters
scene = '6p-c0';

%% Loading paths
% Input video path
video_path = ['Database\Videos\' scene '.mp4'];
% Layout path
layout_path = ['Data\Layout\' scene '.mat'];
% Tracked positions path
tracked_path = ['Data\Tracked Positions\' scene '.mat'];
% Calibration path
calibration_path = ['Database\Calibration\' scene '.mat'];

%% Read video frame
idx = 1824;
video = VideoReader(video_path);
video.CurrentTime = idx;
frame = readFrame(video);

%% Load results and scene layout
load(layout_path);
load(tracked_path);
load(calibration_path);
xyq = gp_xy_tracked{idx};
uv  = gp_uv_tracked{idx};

%% Prepare the x-y data according to the scene viewing perspective
[xyp,ROI,cam,layout_xyp,ax] = prepare_tv_plot(scene, gp_xy_tracked);
xyp = xyp{idx};

%% Occupancy density map in the real-world coordinates
N = 512; % The map number of samples NxN
d = 1;   % Spatial resolution
[Op, xp, yp] = instantaneous_density_map(xyp, layout_xyp, d, N);
Oxy = Op;
[X,Y] = meshgrid(xp,yp);
Oxy(~inpolygon(X,Y,layout_xyp(1,:),layout_xyp(2,:))) = nan;

%% Occupancy density map in the image-pixel coordinates
N = 512; % The map number of samples NxN
d = 1;   % Spatial resolution
[Oq, xq, yq] = instantaneous_density_map(xyq, layout_xy, d, N);
Ouv = xy2uv_mat(Oq,H,Scale,yq,xq,size(frame));
[U,V] = meshgrid(1:size(frame,2),1:size(frame,1));
Ouv(~inpolygon(U,V,layout_uv(1,:),layout_uv(2,:))) = nan;

%% Crowd density map in the real-world coordinates
N = 512; % The map number of samples NxN
d = 1;   % Spatial resolution
r = 2;   % Social safety distance
[~, D, Iv, In] = instantaneous_social_violations(xyq, r);
N_pos = xyp(In,:); % positions following the safety distance guideline
V_pos = xyp(Iv,:); % positions violating the safety distance guideline
Cp = instantaneous_density_map(V_pos, layout_xyp, d, N);
Cxy = Cp;
Cxy(~inpolygon(X,Y,layout_xyp(1,:),layout_xyp(2,:))) = nan;

%% Crowd density map in the image-pixel coordinates
N = 512; % The map number of samples NxN
d = 1;   % Spatial resolution
Cq = instantaneous_density_map(xyq(Iv,:), layout_xy, d, N);
Cuv = xy2uv_mat(Cq,H,Scale,yq,xq,size(frame));
Cuv(~inpolygon(U,V,layout_uv(1,:),layout_uv(2,:))) = nan;

%% Plotting occupancy density map in the real-world coordinates
rp = r + 2; % plotting distance limit in meters
figure('Color',[1,1,1],'Position',[100 100 650 550]);
axes('InnerPosition',[0 0 1 1]); pp = pcolor(xp,yp,Oxy); shading flat;
colormap turbo; set(pp,'FaceAlpha',0.75); caxis([0 max(Oxy(:))]); axis xy; hold on;
plot(ROI,'Facecolor','none','edgecolor','cyan','FaceAlpha',0.2,'linewidth',3);
plot(cam,'Facecolor',[0.7 0.7 0.7],'edgecolor','k','FaceAlpha',1,'linewidth',2);
hold on; box on; grid on; axis(ax);
for i = 1:length(xyp(:,1))
    for j = (i+1):length(xyp(:,1))
        if(D(i,j)>r && D(i,j)<rp)
            plot([xyp(i,1) xyp(j,1)],[xyp(i,2) xyp(j,2)],...
                'linewidth',6/D(i,j),'color',repelem((D(i,j) - r)/(rp-r),1,3));
        elseif(D(i,j)<=r)
            plot([xyp(i,1) xyp(j,1)],[xyp(i,2) xyp(j,2)],...
                'k-','linewidth',7/D(i,j));
        end
        hold on;
    end
end
for i = 1:length(xyp(:,1))
    plot(xyp(i,1),xyp(i,2),'o','Markersize',24,...
        'MarkerFacecolor','y','Color','k','linewidth',2);
end
set(gca,'Xticklabels','','Yticklabels','');
set(gcf,'Units','inches'); screenposition = get(gcf,'Position');
set(gcf,'PaperPosition',[0 0 screenposition(3:4)],'PaperSize',screenposition(3:4));

%% Plotting occupancy density map in the image-pixel coordinates
rp = r + 2; % plotting distance limit in meters
figure('Color',[1,1,1],'Position',[100 100 650 550]);
frame = insertShape(frame,'Polygon',reshape(layout_uv,1,...
    size(layout_uv,1)*size(layout_uv,2)),'Color','cyan','linewidth',2);
axes('InnerPosition',[0 0 1 1]); image(frame); hold on; axis off;
pp = pcolor(Ouv); shading flat; colormap turbo;
caxis([0 max(Ouv(:))]); set(pp,'FaceAlpha',0.3);
for i = 1:length(uv(:,1))
    for j = (i+1):length(uv(:,1))
        if(D(i,j)>r && D(i,j)<rp)
            plot([uv(i,1) uv(j,1)],[uv(i,2) uv(j,2)],...
                'linewidth',6/D(i,j),'color',repelem((D(i,j) - r)/(rp-r),1,3));
        elseif(D(i,j)<=r)
            plot([uv(i,1) uv(j,1)],[uv(i,2) uv(j,2)],'k-','linewidth',7/D(i,j));
        end
        hold on;
    end
end
for i = 1:length(uv(:,1))
    plot(uv(i,1),uv(i,2),'o','Markersize',24,'MarkerFacecolor','y','Color','k','linewidth',2);
end
set(gcf,'Units','inches'); screenposition = get(gcf,'Position');
set(gcf,'PaperPosition',[0 0 screenposition(3:4)],'PaperSize',screenposition(3:4));

%% Plotting crowd density map in the real-world coordinates
figure('Color',[1,1,1],'Position',[100 100 650 550]);
axes('InnerPosition',[0 0 1 1]); pp = pcolor(xp,yp,Cxy); shading flat;
colormap turbo; set(pp,'FaceAlpha',0.75); caxis([0 max(Cxy(:))]); axis xy; hold on;
plot(ROI,'Facecolor','none','edgecolor','cyan','FaceAlpha',0.2,'linewidth',3);
plot(cam,'Facecolor',[0.7 0.7 0.7],'edgecolor','k','FaceAlpha',1,'linewidth',2);
hold on; box on; grid on; axis(ax);
for i = 1:size(N_pos,1)
    plot(N_pos(i,1),N_pos(i,2),'o','Markersize',24,...
        'MarkerFacecolor','g','Color','k','linewidth',2);
end
for i = 1:size(V_pos,1)
    plot(V_pos(i,1),V_pos(i,2),'o','Markersize',24,...
        'MarkerFacecolor','r','Color','k','linewidth',2);
end
set(gca,'Xticklabels','','Yticklabels','');
set(gcf,'Units','inches'); screenposition = get(gcf,'Position');
set(gcf,'PaperPosition',[0 0 screenposition(3:4)],'PaperSize',screenposition(3:4));

%% Plotting crowd density map in the image-pixel coordinates
figure('Color',[1,1,1],'Position',[100 100 650 550]);
frame = insertShape(frame,'Polygon',reshape(layout_uv,1,...
    size(layout_uv,1)*size(layout_uv,2)),'Color','cyan','linewidth',2);
axes('InnerPosition',[0 0 1 1]); image(frame); hold on; axis off;
pp = pcolor(Cuv); shading flat; colormap turbo;
caxis([0 max(Cuv(:))]); set(pp,'FaceAlpha',0.3);
for i = 1:length(In)
    plot(uv(In(i),1),uv(In(i),2),'o','Markersize',24,...
        'MarkerFacecolor','g','Color','k','linewidth',2);
end
for i = 1:length(Iv)
    plot(uv(Iv(i),1),uv(Iv(i),2),'o','Markersize',24,...
        'MarkerFacecolor','r','Color','k','linewidth',2);
end
set(gcf,'Units','inches'); screenposition = get(gcf,'Position');
set(gcf,'PaperPosition',[0 0 screenposition(3:4)],'PaperSize',screenposition(3:4));

%% Saving
opt = input('Do you want to save results (Y/N)\n','s');
if(opt == 'y' || opt == 'Y')
    print(1,'pre_res_real_3','-dpdf','-r400');
    print(2,'pre_res_image_3','-dpdf','-r400');
    print(3,'pre_res_real_4','-dpdf','-r400');
    print(4,'pre_res_image_4','-dpdf','-r400');
end

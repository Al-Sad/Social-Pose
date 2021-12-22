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
% Last Modification: 22-December-2021
%
% Description:
% This demo script produces the results that are depicted in Fig. 8 of the
% paper. It generates an example social distance violation detection results
% using frames 1 to 2005 of the OxTown dataset.

%% Initialization
clear; close all; clc;
addpath(genpath('Functions'));

%% Parameters
scene = 'Towncentre';

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
idx = 2005;
video = VideoReader(video_path);
video.CurrentTime = idx;
frame = readFrame(video);

%% Load results and scene layout
load(layout_path);
load(tracked_path);
load(calibration_path);
xyq = gp_xy_tracked(1:idx);
uv  = gp_uv_tracked(1:idx);

%% Prepare the x-y data according to the scene viewing perspective
[xyp,ROI,cam,layout_xyp,ax] = prepare_tv_plot(scene, gp_xy_tracked);
xyp = xyp(1:idx);

%% Averaged occupancy density map in the image-pixel coordinates
N = 512; % The map number of samples NxN
d = 1;   % Spatial resolution
[Oq, xq, yq] = density_map(xyq, layout_xy, d, N);
Ouv = xy2uv_mat(Oq,H,Scale,yq,xq,size(frame));
[U,V] = meshgrid(1:size(frame,2),1:size(frame,1));
Ouv(~inpolygon(U,V,layout_uv(1,:),layout_uv(2,:))) = nan;

%% Averaged crowd density map in the real-world coordinates
N = 512; % The map number of samples NxN
d = 1;   % Spatial resolution
r = 2;   % Social safety distance
[~,Vp] = social_violations(xyp,r);
[Cp, xp, yp] = density_map(Vp,layout_xyp,d,N);
Cxy = Cp; [X,Y] = meshgrid(xp,yp);
Cxy(~inpolygon(X,Y,layout_xyp(1,:),layout_xyp(2,:))) = nan;

%% Instantanuous social distance violations
[~, D, Iv, In] = instantaneous_social_violations(xyq{end}, r);

%% Plotting averaged crowd density map in the image-pixel coordinates
figure('Color',[1,1,1],'Position',[100 100 650 550]);
frame = insertShape(frame,'Polygon',reshape(layout_uv,1,...
    size(layout_uv,1)*size(layout_uv,2)),'Color','cyan','linewidth',2);
axes('InnerPosition',[0 0 1 1]); image(frame); hold on; axis off;
pp = pcolor(Ouv); shading flat; colormap turbo;
caxis([0 max(Ouv(:))]); set(pp,'FaceAlpha',0.3);
for i = 1:length(In)
    plot(uv{end}(In(i),1),uv{end}(In(i),2),'o','Markersize',12,...
        'MarkerFacecolor','g','Color','k','linewidth',2);
end
for i = 1:length(Iv)
    plot(uv{end}(Iv(i),1),uv{end}(Iv(i),2),'o','Markersize',12,...
        'MarkerFacecolor','r','Color','k','linewidth',2);
end
set(gcf,'Units','inches'); screenposition = get(gcf,'Position');
set(gcf,'PaperPosition',[0 0 screenposition(3:4)],'PaperSize',screenposition(3:4));

%% Plotting averaged crowd density map in the real-world coordinates
NL = 10;     % Number of contour levels
figure('Color',[1,1,1],'Position',[100 100 650 550]);
axes('InnerPosition',[0 0 1 1]); contourf(xp,yp,Cxy,linspace(0,max(Cxy(:)),NL));
shading flat; colormap parula; caxis([0 max(Cxy(:))]); axis xy; hold on;
plot(ROI,'Facecolor','none','edgecolor','cyan','FaceAlpha',0.2,'linewidth',3);
plot(cam,'Facecolor',[0.7 0.7 0.7],'edgecolor','k','FaceAlpha',1,'linewidth',2);
hold on; box on; grid on; axis(ax);
for i = 1:length(xyp{end}(:,1))
    for j = (i+1):length(xyp{end}(:,1))
        if(D(i,j)<=r)
            plot([xyp{end}(i,1) xyp{end}(j,1)],[xyp{end}(i,2) xyp{end}(j,2)],...
                'linewidth',5,'color','r');
        end
        hold on;
    end
end
for i = 1:length(In)
    plot(xyp{end}(In(i),1),xyp{end}(In(i),2),'o','Markersize',12,...
        'MarkerFacecolor','g','Color','k','linewidth',2);
end
for i = 1:length(Iv)
    plot(xyp{end}(Iv(i),1),xyp{end}(Iv(i),2),'o','Markersize',12,...
        'MarkerFacecolor','r','Color','k','linewidth',2);
end
set(gca,'Xticklabels','','Yticklabels','');
set(gcf,'Units','inches'); screenposition = get(gcf,'Position');
set(gcf,'PaperPosition',[0 0 screenposition(3:4)],'PaperSize',screenposition(3:4));

%% Saving
opt = input('Do you want to save results (Y/N)\n','s');
if(opt == 'y' || opt == 'Y')
    print(1,'example_frame_1','-dpdf','-r400');
    print(2,'example_frame_2','-dpdf','-r400');
end

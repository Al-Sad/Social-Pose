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
% M. Al-Sa'd, S. Kiranyaz, M. Gabbouj, "A machine learning-based social
% distance estimation and crowd monitoring system for surveillance cameras",
% IEEE Transactions on Pattern Analysis and Machine Intelligence, 2021.
%
% Last Modification: 15-September-2021
%
% Description:
% This main script produces the proposed system integrated video frames and
% dynamic top-view maps. It generates the integrated results and saves them
% in video format in the "Integrated Videos" folder under "Data". Note that
% the provided videos are compressed to minimize their size, but one can
% execute this code to generate the original high-resolution videos for
% each sequence.

%% Initialization
clear; close all; clc; warning off;
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

%% Saving paths
video_out_path = ['Data\Integrated Videos\' scene];

%% Initiate video reader
video = VideoReader(video_path);
video.CurrentTime = 0;

%% Initiate video writer
Video = VideoWriter(video_out_path,'MPEG-4');
switch lower(scene)
    case {'6p-c0','6p-c1','6p-c2','6p-c3','oxtown'}
        Video.FrameRate = 25;
    case {'c1','c2','c3','c4','c5','c6','c7'}
        Video.FrameRate = 2;
end
open(Video);

%% Load results and scene layout
load(layout_path);
load(tracked_path);
load(calibration_path);

%% Prepare the x-y data according to the scene viewing perspective
[xy,ROI,cam,layout_xyp,fx] = prepare_tv_plot(scene, gp_xy_tracked);

%% Main
N       = 512;   % The map number of samples NxN
r       = 2;     % Social safety distance
rp      = r + 1; % plotting distance limit in meters
d       = 1;     % Spatial resolution
thresh  = 0.5;   % Energy threshold between 0 and 1
cnt1    = video.CurrentTime;
cnt2    = 0;
Oxy     = zeros(N);
Cxy     = zeros(N);
Cpq     = zeros(N);
Ouv_avg = zeros(video.Height,video.Width);
Cxy_avg = zeros(N);
Ruv_avg = zeros(video.Height,video.Width);
[U,V]   = meshgrid(1:video.Width,1:video.Height);
Lx      = [min(layout_xyp(1,:)) max(layout_xyp(1,:))];
Ly      = [min(layout_xyp(2,:)) max(layout_xyp(2,:))];
xp      = linspace(Lx(1)-3,Lx(2)+3,N);
yp      = linspace(Ly(1)-3,Ly(2)+3,N);
[X,Y]   = meshgrid(xp,yp);
while hasFrame(video)
    cnt1 = cnt1 + 1;
    % Read frame and append ROI
    frame = readFrame(video);
    frame = insertShape(frame,'Polygon',reshape(layout_uv,1,...
        size(layout_uv,1)*size(layout_uv,2)),'Color','cyan','linewidth',2);
    % Get current tracks
    xyp = xy{cnt1};
    xyq = gp_xy_tracked{cnt1};
    uv  = gp_uv_tracked{cnt1};
    
    if(~isempty(xyp))
        cnt2 = cnt2 + 1;
        % Occupancy density map
        [Oq, xq, yq] = instantaneous_density_map(xyq, layout_xy, 1, N);
        Oxy = Oxy + Oq;
        Oxy_avg = Oxy./cnt2;
        Ouv_avg = xy2uv_mat(Oxy_avg,H,Scale,yq,xq,size(frame));
        % Crowd density map
        [~, D, Iv, In] = instantaneous_social_violations(xyp,r);
        Cp = instantaneous_density_map(xyp(Iv,:), layout_xyp, 1, N);
        Cq = instantaneous_density_map(xyq(Iv,:), layout_xy, 1, N);
        Cxy = Cxy + Cp;
        Cpq = Cpq + Cq;
        Cxy_avg = Cxy./cnt2;
        C_avg   = Cpq./cnt2;
        % Overcrowded regions
        thr = linspace(0,max(C_avg(:)),100);
        for k = 1:length(thr)
            E = sum(C_avg(C_avg > thr(k)),'all')/sum(C_avg,'all');
            if(E <= thresh)
                break;
            end
        end
        Rxy = double(C_avg > thr(k-1));
        Ruv_avg = double(xy2uv_mat(Rxy,H,Scale,yq,xq,size(frame))>0);
    else
        Iv = [];
        In = [];
    end
    Ouv_plot = Ouv_avg;
    Ouv_plot(~inpolygon(U,V,layout_uv(1,:),layout_uv(2,:))) = nan;
    Ouv_plot(Ouv_plot==0) = nan;
    Cxy_plot = Cxy_avg;
    Cxy_plot(~inpolygon(X,Y,layout_xyp(1,:),layout_xyp(2,:))) = nan;
    Ruv_plot = Ruv_avg;
    Ruv_plot(~inpolygon(U,V,layout_uv(1,:),layout_uv(2,:))) = nan;
    Ruv_plot(Ruv_plot==0) = nan;
    % Struct the first integrated frame
    figure('Color',[1,1,1],'Position',[10 100 650 550],'visible','off'); colormap turbo;
    axes('InnerPosition',[0 0 1 1]); image(frame); axis off; hold on;
    pp = pcolor(Ouv_plot); shading flat;
    if(sum(Ouv_plot,'all')>0)
        caxis([0 max(Ouv_plot(:))]);
    end
    set(pp,'FaceAlpha',0.3);
    for i = 1:size(uv,1)
        plot(uv(i,1),uv(i,2),'o','Markersize',10,...
            'MarkerFacecolor','y','Color','k','linewidth',2);
    end
    % Struct the second integrated frame
    figure('Color',[1,1,1],'Position',[10 100 650 550],'visible','off'); colormap turbo;
    axes('InnerPosition',[0 0 1 1]); image(frame); axis off; hold on;
    pp = pcolor(Ruv_plot); shading flat;
    caxis([0 1]); set(pp,'FaceAlpha',0.3);
    for i = 1:length(In)
        plot(uv(In(i),1),uv(In(i),2),'o','Markersize',10,'MarkerFacecolor',...
            'g','Color','k','linewidth',2);
    end
    for i = 1:length(Iv)
        plot(uv(Iv(i),1),uv(Iv(i),2),'o','Markersize',10,'MarkerFacecolor',...
            'r','Color','k','linewidth',2);
    end
    % Struct the dynamic top-view map
    figure('Color',[1,1,1],'Position',[10 100 650 550],'visible','off'); colormap parula;
    axes('InnerPosition',[0 0 1 1]); contourf(xp,yp,Cxy_plot,linspace(0,max(Cxy_plot(:)),5));
    shading flat; colormap parula; caxis([0 max(Cxy_plot(:))]); axis xy; hold on;
    plot(ROI,'Facecolor','none','edgecolor','cyan','FaceAlpha',0.2,'linewidth',3);
    plot(cam,'Facecolor',[0.7 0.7 0.7],'edgecolor','k','FaceAlpha',1,'linewidth',2);
    hold on; box on; grid on; axis(fx);
    for i = 1:size(xyp,1)
        for j = (i+1):size(xyp,1)
            if(D(i,j)>r && D(i,j)<rp)
                plot([xyp(i,1) xyp(j,1)],[xyp(i,2) xyp(j,2)],...
                    'linewidth',2,'color','k');
            elseif(D(i,j)<=r)
                plot([xyp(i,1) xyp(j,1)],[xyp(i,2) xyp(j,2)],...
                    'linewidth',5,'color','r');
            end
        end
    end
    for i = 1:length(In)
        plot(xyp(In(i),1),xyp(In(i),2),'o','Markersize',10,'MarkerFacecolor',...
            'g','Color','k','linewidth',2);
    end
    for i = 1:length(Iv)
        plot(xyp(Iv(i),1),xyp(Iv(i),2),'o','Markersize',10,'MarkerFacecolor',...
            'r','Color','k','linewidth',2);
    end
    set(gca,'Xticklabels','','Yticklabels','');
    % Combine all plots
    C1 = print(1,'-RGBImage','-r256');
    C2 = print(2,'-RGBImage','-r256');
    C3 = print(3,'-RGBImage','-r256');
    C = [C1, C2, C3];
    % Write the video integrated frame
    writeVideo(Video,im2frame(C));
    disp(100*cnt1./video.NumFrames);
    close ALL HIDDEN;
end
close(Video)
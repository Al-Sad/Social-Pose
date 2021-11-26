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
% This demo script produces the results that are depicted in Fig. 4e of the
% paper. It transforms the subjects estimated ground positions from the
% image-pixel to the real-world coordinates resulting in a top-view
% depiction for the scene.

%% Initialization
clear; close all; clc;
addpath(genpath('Functions'));

%% Parameters
scene = '6p-c0';

%% Loading paths
% Input video path
video_path = ['Database\Videos\' scene '.mp4'];
% Top view position path
top_view_path = ['Data\Top View Positions\' scene '.mat'];

%% Read video frame
idx = 1824;
video = VideoReader(video_path);
video.CurrentTime = idx;
frame = readFrame(video);

%% Load results
load(top_view_path);

%% Prepare the x-y data according to the scene viewing perspective
[xy_basic,ROI,cam] = prepare_tv_plot(scene, gp_xy_basic_confirmed);
[xy_proposed,~,~,~,ax] = prepare_tv_plot(scene, gp_xy_proposed_confirmed);

%% Plotting
figure('Color',[1,1,1],'Position',[100 100 650 550]); axes('InnerPosition',[0 0 1 1]);
plot(ROI,'Facecolor','cyan','edgecolor','cyan','FaceAlpha',0.2,'linewidth',3); hold on;
plot(cam,'Facecolor',[0.7 0.7 0.7],'edgecolor','k','FaceAlpha',1,'linewidth',2);
CC = [0.7 0.7 0.7; 1 0 0; 1 0.7 0; 0.39 0.83 0.07]; % Color vector
for i = 1:length(xy_proposed{idx}(:,1))
    plot(xy_proposed{idx}(i,1),xy_proposed{idx}(i,2),'sq','Markersize',...
        24,'MarkerFacecolor',CC(i,:),'Color','k','linewidth',2);
end
CC = [1 0 0; 1 0.7 0; 0.39 0.83 0.07]; % Color vector
for i = 1:length(xy_basic{idx}(:,1))
    plot(xy_basic{idx}(i,1),xy_basic{idx}(i,2),'v','Markersize',...
        18,'MarkerFacecolor',CC(i,:),'Color','k','linewidth',2);
end
grid on; axis(ax); set(gca,'Xticklabels','','Yticklabels','');
set(gcf,'Units','inches'); screenposition = get(gcf,'Position');
set(gcf,'PaperPosition',[0 0 screenposition(3:4)],'PaperSize',screenposition(3:4));

%% Saving
opt = input('Do you want to save results (Y/N)\n','s');
if(opt == 'y' || opt == 'Y')
    print(1,'pre_res_real_1','-dpdf','-r400');
end

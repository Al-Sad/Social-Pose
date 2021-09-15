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
% This demo script produces the results that are depicted in Fig. 4a of the
% paper. It generates the subjects estimated ground positions in the
% image-pixel coordinates using the poses illustrated in Fig. 3. Besides,
% it compares the proposed localization strategy with the basic approach.

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
% Ground position detection path
detection_path = ['Data\Ground Position Detections\' scene '.mat'];

%% Read video frame
idx = 1824;
video = VideoReader(video_path);
video.CurrentTime = idx;
frame = readFrame(video);

%% Load results and scene layout
load(detection_path);
load(layout_path);

%% Plotting
figure('Color',[1,1,1],'Position',[100 100 650 550]);
frame = insertShape(frame,'Polygon',reshape(layout_uv,1,...
    size(layout_uv,1)*size(layout_uv,2)),'Color','cyan','linewidth',2);
frame = insertShape(frame,'FilledPolygon',reshape(layout_uv,1,...
    size(layout_uv,1)*size(layout_uv,2)),'Color','cyan','Opacity',0.15);
axes('InnerPosition',[0 0 1 1]); image(frame); hold on; axis off;
CC = [0.7 0.7 0.7; 1 0 0; 1 0.7 0; 0.39 0.83 0.07]; % Color vector
for i = 1:length(gp_uv_proposed_confirmed{idx}(:,1))
    plot(gp_uv_proposed_confirmed{idx}(i,1),gp_uv_proposed_confirmed{idx}(i,2),...
        'sq','Markersize',24,'MarkerFacecolor',CC(i,:),'Color','k','linewidth',2);
end
CC = [1 0 0; 1 0.7 0; 0.39 0.83 0.07]; % Color vector
for i = 1:length(gp_uv_basic_confirmed{idx}(:,1))
    plot(gp_uv_basic_confirmed{idx}(i,1),gp_uv_basic_confirmed{idx}(i,2),...
        'v','Markersize',18,'MarkerFacecolor',CC(i,:),'Color','k','linewidth',2);
end
set(gcf,'Units','inches'); screenposition = get(gcf,'Position');
set(gcf,'PaperPosition',[0 0 screenposition(3:4)],'PaperSize',screenposition(3:4));

%% Saving
opt = input('Do you want to save results (Y/N)\n','s');
if(opt == 'y' || opt == 'Y')
    print(1,'pre_res_image_1','-dpdf','-r400');
end
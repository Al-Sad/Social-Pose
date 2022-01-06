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
% cameras", Sensors, (2022), https://doi.org/10.3390/s22020418.
%
% Last Modification: 12-November-2021
%
% Description:
% This demo script produces the results that are depicted in Fig. 3 of the
% paper. It generates the pose estimations for the subjects in frame 1824
% of the Epfl-Mpv 6p-c0 video sequence.

%% Initialization
clear; close all; clc;
addpath(genpath('Functions'));

%% Parameters
scene = '6p-c0';

%% Loading paths
% Input video path
video_path = ['Database\Videos\' scene '.mp4'];
% Pose estimation path
pose_estimation_path = ['Database\HumanJoints\' scene '.mat'];

%% Read video frame
idx = 1824;
video = VideoReader(video_path);
video.CurrentTime = idx;
frame = readFrame(video);

%% Loading pose estimations
load(pose_estimation_path);
[Jx, Jy] = generate_poses(joints{idx});

%% Plotting
CC = [0.7 0.7 0.7; 1 0 0; 1 0.7 0; 0.39 0.83 0.07; 0.07 0.62 1]; % Color vector
figure('Color',[1,1,1],'Position',[100 100 650 550]);
axes('InnerPosition',[0 0 1 1]); image(frame); hold on; axis off;
for i = 1:length(Jx)
    for j = 1:size(Jx{i},1)
        plot(Jx{i}(j,:),Jy{i}(j,:),'.-','Markersize',18,...
            'Color',CC(i,:),'linewidth',3);
    end
end
set(gcf,'Units','inches'); screenposition = get(gcf,'Position');
set(gcf,'PaperPosition',[0 0 screenposition(3:4)],'PaperSize',screenposition(3:4));

%% Saving
opt = input('Do you want to save results (Y/N)\n','s');
if(opt == 'y' || opt == 'Y')
    print(1,'pose_estimation','-dpdf','-r400');
end

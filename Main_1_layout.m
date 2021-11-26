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
% This main script generates the user selected region of interest (ROI) for
% the scene. The ROI is manually selected in the image-pixel domain and then
% transformed to the real-world coordinates. The ROIs in both domains are
% saved in the "Layout" folder under "Data".

%% Initialization
clear; close all; clc;
addpath(genpath('Functions'));

%% Parameters
scene = '6p-c0';

%% Select TOI in the image-pixel coordinates
switch lower(scene)
    case '6p-c0', ROI_uv = [1 125; 175 69 ;360 131; 360 288; 1 288];
    case '6p-c1', ROI_uv = [1 125; 200 72 ;360 118; 360 288; 1 288];
    case '6p-c2', ROI_uv = [17 127; 195 90; 310 121; 310 255; 17 255];
    case '6p-c3', ROI_uv = [1 130; 185 85 ;370 145; 370 288; 1 288];
    case 'towncentre', ROI_uv = [1 520; 940 75; 1920 105; 1920 1080; 1 1080];
    case 'c1', ROI_uv = [1 450; 1220 195; 1870 220; 1695 1080; 1 1080];
    case 'c2', ROI_uv = [1 365 ; 1405 87; 1920 87; 1920 1080; 1 1080];
    case 'c3', ROI_uv = [385 1080; 122 280; 800 205; 1920 430; 1920 1080];
    case 'c4', ROI_uv = [265 460; 1380 350; 1920 530; 1920 1080; 265 1080];
    case 'c5', ROI_uv = [1 445; 1920 410; 1920 1080; 1 1080];
    case 'c6', ROI_uv = [225 1080; 125 215; 715 195; 1920 460; 1920 1080];
    case 'c7', ROI_uv = [1 370; 1920 240; 1920 1080; 1 1080];
end

%% Top-View transformation of the ROI
load(['Database\Calibration\' scene '.mat']);
layout_uv = ROI_uv';
xyz = H*[layout_uv; ones(1,size(layout_uv,2))];
xyz = xyz./xyz(3,:);
layout_xy = (1/Scale).*xyz(1:2,:);

%% Saving
save(['Data\Layout\' scene '.mat'],'layout_xy','layout_uv');

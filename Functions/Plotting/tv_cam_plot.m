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
% cameras", Future Generation Computer Systems, (2021).
%
% Last Modification: 12-November-2021
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                   Preparing The Scene Top-View Layout
%
%  Syntax : [ROI, cam, layout_xy, tv_ax] = tv_cam_plot(scene)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% <INPUTs>
% scene : The video sequence scene string.
%
% <OUTPUTs>
% ROI       : The ROI polygon in the real-world coordinates.
% cam       : The camera polygon in the real-world coordinates.
% layout_xy : The prepared layout in the real-world coordinates.
% tv_ax     : The top-view axes limits.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [ROI, cam, layout_xy, tv_ax] = tv_cam_plot(scene)
switch lower(scene)
    case '6p-c0'
        Scale = [0.25; 0.25]; Shift = [6.95; 7.25]; Theta = 45; c = 1;
    case '6p-c1'
        Scale = [0.25; 0.25]; Shift = [6.5; 0.5]; Theta = -45; c = 1;
    case '6p-c2'
        Scale = [0.25; 0.25]; Shift = [1; 1]; Theta = 230; c = 1;
    case '6p-c3'
        Scale = [0.25; 0.25]; Shift = [0.5; 6.2]; Theta = 135; c = 1;
    case 'towncentre'
        Scale = [0.5; 1]; Shift = [0; 0]; Theta = 290; c = -1;
    case 'c1'
        Scale = [1.25; 0.4]; Shift = [7; 8.7]; Theta = 25; c = -1;
    case 'c2'
        Scale = [1.25; 0.4]; Shift = [-27; -1.5]; Theta = 220; c = -1;
    case 'c3'
        Scale = [1.25; 0.5]; Shift = [-19; 8.5]; Theta = 150; c = -1;
    case 'c4'
        Scale = [0.5; 0.5]; Shift = [6.5; 8.5]; Theta = 50; c = -1;
    case 'c5'
        Scale = [0.6; 0.5]; Shift = [-9.5; -2]; Theta = -100; c = -1;
    case 'c6'
        Scale = [1.25; 0.5]; Shift = [10; -1]; Theta = -30; c = -1;
    case 'c7'
        Scale = [0.7; 0.5]; Shift = [-2; 10]; Theta = 60; c = -1;
end
cam = tv_camera_poly(Scale, Shift, Theta);
load([pwd '\Data\Layout\' scene '.mat'],'layout_xy');
layout_xy(2,:) = c.*layout_xy(2,:);
ROI = polyshape(layout_xy(2,:),layout_xy(1,:));
layout_xy = flipud(layout_xy);
AX = [layout_xy cam.Vertices'];
tv_ax = [min(AX(1,:)) max(AX(1,:)) min(AX(2,:)) max(AX(2,:))];
end
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
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                  Threhsolded Averaged Crowd Density Map
%
%  Syntax : [R, D, x, y] = density_map_thresh(xy, layout_xy, r, thresh, N)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% <INPUTs>
% xy        : The ground positions in the video sequence as a cell array in
%             the real-world coordinates.
% layout_xy : The ROI layout in the real-world coordinates.
% r         : The spatial resolution in meters.
% thresh    : Energy threshold between 0 and 1.
% N         : The density mesh size (NxN).
%
% <OUTPUTs>
% R : The threhsolded crowd density map averaged across the video frames.
% D : The normalized crowd density map averaged across the video frames.
% x : The map x-coordinates.
% y : The map y-coordinates.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [R, D, x, y] = density_map_thresh(xy, layout_xy, r, thresh, N)
% Initialization
Lx = [min(layout_xy(1,:)) max(layout_xy(1,:))];
Ly = [min(layout_xy(2,:)) max(layout_xy(2,:))];
x  = linspace(Lx(1)-3*r,Lx(2)+3*r,N);
y  = linspace(Ly(1)-3*r,Ly(2)+3*r,N);

% Density map
cnt = 0;
D = 0;
for i = 1:length(xy)
    if(~isempty(xy{i}))
        cnt = cnt + 1;
        d = Gauss_spatial_density(xy{i}',r,x,y,Lx,Ly,N);
        D = D + d;
    end
end
D_norm = D./cnt;
D = D./max(D(:));

% Thresholding
thr = linspace(0,max(D_norm(:)),100);
for k = 1:length(thr)
    E = sum(D_norm(D_norm > thr(k)),'all')/sum(D_norm,'all');
    if(E <= thresh)
        break;
    end
end
R = logical(D_norm > thr(k-1));
end

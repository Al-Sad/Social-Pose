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
%                Instantaneous Occupancy/Crowd Density Map
%
%  Syntax : [O, x, y] = instantaneous_density_map(xy, layout_xy, r, N)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% <INPUTs>
% xy        : The instantaneous ground positions in the real-world
%             coordinates.
% layout_xy : The ROI layout in the real-world coordinates.
% r         : The spatial resolution in meters.
% N         : The density mesh size (NxN).
%
% <OUTPUTs>
% O : The instantaneous occupancy/crowd density map.
% x : The map x-coordinates.
% y : The map y-coordinates.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [O, x, y] = instantaneous_density_map(xy, layout_xy, r, N)
% Initialization
Lx = [min(layout_xy(1,:)) max(layout_xy(1,:))];
Ly = [min(layout_xy(2,:)) max(layout_xy(2,:))];
x  = linspace(Lx(1)-3,Lx(2)+3,N);
y  = linspace(Ly(1)-3,Ly(2)+3,N);

% Density map
if(~isempty(xy))
    O = Gauss_spatial_density(xy',r,x,y,Lx,Ly,N);
else
    O = zeros(N,N);
end
end
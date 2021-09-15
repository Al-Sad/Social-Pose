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
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%   Preparing The Top-View Positions According To The Scene Perspective
%
%  Syntax : [xy,ROI,cam,layout_xy,tv_ax] = prepare_tv_plot(scene, gp)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% <INPUTs>
% scene : The video sequence string.
% gp    : The ground positions in the video sequence as a cell array in
%         the real-world coordinates.
%
% <OUTPUTs>
% xy        : The prepared positions in the video sequence as a cell array
%             in the real-world coordinates.
% ROI       : The ROI polygon in the real-world coordinates.
% cam       : The camera polygon in the real-world coordinates.
% layout_xy : The prepared layout in the real-world coordinates.
% tv_ax     : The top-view axes limits.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [xy,ROI,cam,layout_xy,tv_ax] = prepare_tv_plot(scene, gp)
xy = cell(size(gp));
[ROI, cam, layout_xy, tv_ax] = tv_cam_plot(scene);
switch lower(scene)
    case {'6p-c0','6p-c1','6p-c2','6p-c3'}
        c = [1, 1];
    case 'towncentre'
        c = [-1, 1];
    case {'c1','c2','c3','c4','c5','c6','c7'}
        c = [-1, 1];
end
for i = 1:length(gp)
    if(~isempty(gp{i}))
        xy{i} = fliplr(gp{i}).*c;
    else
        xy{i} = fliplr(gp{i});
    end
end
end
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
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                             Pose Rendering
%
%  Syntax : [Jx_out, Jy_out] = generate_poses(poses)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% <INPUTs>
% poses : The estimated poses in a frame.
%
% <OUTPUTs>
% Jx_out : The rendered pose x-coordinates.
% Jy_out : The rendered pose y-coordinates.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [Jx_out, Jy_out] = generate_poses(poses)
Jx_out = cell(1,size(poses,1));
Jy_out = cell(1,size(poses,1));
idy = zeros(size(poses,1),24);
joint_conn = [1 8; 1 2; 1 5; 0 15; 0 16; 15 17; 16 18; 1 0; 2 3; 3 4; 5 6;
    6 7; 8 9; 8 12; 9 10; 12 13; 10 11; 13 14; 11 24; 11 22; 22 23; 14 21;
    14 19; 19 20];
joint_conn = joint_conn + 1;
for i = 1:size(poses,1)
    Jx = zeros(size(joint_conn,1),2);
    Jy = zeros(size(joint_conn,1),2);
    for j = 1:size(joint_conn,1)
        x1 = poses(i,1,joint_conn(j,1));
        x2 = poses(i,1,joint_conn(j,2));
        y1 = poses(i,2,joint_conn(j,1));
        y2 = poses(i,2,joint_conn(j,2));
        Jx(j,:) = [x1 x2];
        Jy(j,:) = [y1 y2];
    end
    Jx_out{i} = Jx;
    Jy_out{i} = Jy;
    % Remove nan entries
    idy(i,:) = all(~isnan([Jx Jy]),2);
    Jx_out{i}(~idy(i,:),:) = [];
    Jy_out{i}(~idy(i,:),:) = [];
end

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
%               The Image-Pixel To Real-World Transformation
%
%  Syntax : gp_xy = uv2xy(gp_uv,H,s)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% <INPUTs>
% gp_uv : The ground positions in the video sequence as a cell array in the
%         image-pixel coordinates.
% H     : The top-view transformation matrix, a.k.a. homography matrix.
% s     : The image-to-real distance scale.
%
% <OUTPUTs>
% gp_xy : The ground positions in the video sequence as a cell array in the
%         real-world coordinates.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function gp_xy = uv2xy(gp_uv,H,s)
gp_xy = cell(size(gp_uv));
for i = 1:length(gp_uv)
    if(~isempty(gp_uv{i}))
        u     = gp_uv{i}(:,1);
        v     = gp_uv{i}(:,2);
        uv    = [u'; v'; ones(1,length(u))];
        xyz   = H*uv;
        xyz   = xyz./xyz(3,:);
        gp_xy{i} = (1/s).*xyz(1:2,:)';
    else
        gp_xy{i} = [];
    end
end
end

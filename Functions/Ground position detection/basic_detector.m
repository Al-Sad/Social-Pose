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
%                       Basic Localization Strategy
%
%  Syntax : [gp_con, gp_all] = basic_detector(poses,layout_uv)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% <INPUTs>
% poses     : The estimated poses in the video sequence as a cell array.
% layout_uv : The ROI layout in the image-pixel coordinates.
%
% <OUTPUTs>
% gp_con : Confirmed ground positions (within the ROI) in the video
%          sequence as a cell array.
% gp_all : All ground positions (within and outside the ROI) in the video
%          sequence as a cell array.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function  [gp_con, gp_all] = basic_detector(poses,layout_uv)
gp_con = cell(1,length(poses));
gp_all = cell(1,length(poses));
for i = 1:length(poses)
    if(~isempty(poses{i}))
        cond1 = squeeze(sum(~isnan(sum(poses{i},2)),3)) >= 13;
        cond2 = squeeze(sum(~isnan(poses{i}(:,:,[12 15 20 21 22 23 24 25])),[2,3])) > 0;
        cond  = cond1 & cond2;
        u   = zeros(sum(cond),1);
        v   = zeros(sum(cond),1);
        cnt = 0;
        for j = 1:length(cond)
            if(cond(j))
                cnt = cnt + 1;
                if(any(~isnan(poses{i}(j,1,[1 2 9]))))
                    u(cnt) = mean(poses{i}(j,1,[1 2 9]),3,'omitnan');
                else
                    u(cnt) = mean(poses{i}(j,1,:),3,'omitnan');
                end
                v(cnt) = mean(poses{i}(j,2,[12 15 20 21 22 23 24 25]),3,'omitnan');
            end
        end
        uv = [u v];
        uv = uv(~any(isnan(uv),2),:);
        gp_con{i} = uv(inpolygon(uv(:,1),uv(:,2),layout_uv(1,:),layout_uv(2,:)),:);
        gp_all{i} = uv;
    else
        gp_con{i} = [];
        gp_all{i} = [];
    end
end
end
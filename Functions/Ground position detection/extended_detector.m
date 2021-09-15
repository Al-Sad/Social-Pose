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
%                      Proposed Localization Strategy
%
%  Syntax : [gp_con, gp_all, Ft] = extended_detector(poses,layout_uv)
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
% Ft     : Localization error flag for all positions in the video sequence
%          as a cell array.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [gp_con, gp_all, Ft] = extended_detector(poses,layout_uv)
gp_con = cell(1,length(poses));
gp_all = cell(1,length(poses));
Ft     = cell(1,length(poses));
for i = 1:length(poses)
    if(~isempty(poses{i}))
        uv  = zeros(size(poses{i},1),2);
        Fu = zeros(size(poses{i},1),1);
        Fv = zeros(size(poses{i},1),1);
        cnt = 0;
        for j = 1:size(poses{i},1)
            cnt = cnt + 1;
            beta  = mean(poses{i}(j,1,[12 23 24 25]),3,'omitnan');
            alpha = mean(poses{i}(j,1,[15 20 21 22]),3,'omitnan');
            % Ground position x-coordinate estimation
            switch true
                case (all(~isnan([alpha beta])))
                    u = mean([alpha beta]);
                    Fu(cnt,1) = 1; % x coordinate is detected
                case (~isnan(alpha) && ~isnan(poses{i}(j,1,11)))
                    u = mean([alpha poses{i}(j,1,11)]);
                    Fu(cnt,1) = 2; % x coordinate is adjusted
                case (~isnan(poses{i}(j,1,14)) && ~isnan(beta))
                    u = mean([poses{i}(j,1,14) beta]);
                    Fu(cnt,1) = 2; % x coordinate is adjusted
                case (all(~isnan(poses{i}(j,1,[11 14]))))
                    u = mean(poses{i}(j,1,[11 14]));
                    Fu(cnt,1) = 2; % x coordinate is adjusted
                case (~isnan(poses{i}(j,1,10)) && ~isnan(poses{i}(j,1,14)))
                    u = mean([poses{i}(j,1,10) poses{i}(j,1,14)]);
                    Fu(cnt,1) = 2; % x coordinate is adjusted
                case (~isnan(poses{i}(j,1,11)) && ~isnan(poses{i}(j,1,13)))
                    u = mean([poses{i}(j,1,11) poses{i}(j,1,13)]);
                    Fu(cnt,1) = 2; % x coordinate is adjusted
                case (all(~isnan(poses{i}(j,1,[10 13]))))
                    u = mean(poses{i}(j,1,[10 13]));
                    Fu(cnt,1) = 2; % x coordinate is adjusted
                case (all(~isnan(poses{i}(j,1,[2 9]))))
                    u = mean(poses{i}(j,1,[2 9]));
                    Fu(cnt,1) = 2; % x coordinate is adjusted
                case (any(~isnan([alpha beta])))
                    u = mean([alpha beta],2,'omitnan');
                    Fu(cnt,1) = 2; % x coordinate is adjusted
                otherwise
                    u = nan;
                    Fu(cnt,1) = 0; % x coordinate is not detected
            end
            % Ground position y-coordinate checkup
            gamma = [mean(poses{i}(j,2,[15 20 21 22]),3,'omitnan')...
                mean(poses{i}(j,2,[12 23 24 25]),3,'omitnan')];
            % Ground position y-coordinate estimation
            switch true
                case(any(~isnan(gamma))) % this includes when both feets are detected
                    v = mean(gamma,'omitnan');
                    Fv(cnt,1) = 1; % y coordinate is detected
                case(all(~isnan(poses{i}(j,2,[2 9]))))
                    v = poses{i}(j,2,9) + (0.85/0.6)*(abs(poses{i}(j,2,2) - poses{i}(j,2,9)));
                    Fv(cnt,1) = 2; % y coordinate is detected
                otherwise
                    v = nan;
                    Fv(cnt,1) = 0; % y coordinate is not detected
            end
            % Ground position
            uv(cnt,:) = [u v];
        end
        uv = uv(~any(isnan(uv),2),:);
        gp_con{i} = uv(inpolygon(uv(:,1),uv(:,2),layout_uv(1,:),layout_uv(2,:)),:);
        gp_all{i} = uv;
        temp  = Fu.*Fv;
        temp(temp > 2) = 2;
        Ft{i} = temp;
    else
        gp_con{i} = [];
        gp_all{i} = [];
        Ft{i}     = [];
    end
end
end
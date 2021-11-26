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
%                 The Smoothing & Tracking Distance Function
%
%  Syntax : cost = KF_distnace_cost(gp_true,gp_pred)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% <INPUTs>
% gp_true   : The true ground positions in the video sequence as a cell
%             array in the real-world coordinates.
% gp_pred   : The tracked ground positions in the video sequence as a cell
%             array in the real-world coordinates.
%
% <OUTPUTs>
% cost : The smoothing and tracking distance cost to be minimized.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function cost = KF_distnace_cost(gp_true,gp_pred)
cost = 0;
for k = 1:length(gp_true)
    xy_true = gp_true{k};
    xy_pred = gp_pred{k};
    N = size(xy_true,1);
    M = size(xy_pred,1);
    if(~isempty(xy_true) && ~isempty(xy_pred))
        Diff = zeros(M,N);
        for i = 1:M
            Diff(i,:) = sqrt(sum((xy_pred(i,:) - xy_true).^2,2));
        end
        I = munkres(Diff);
        if(M > N)
            c = mean(Diff(I)./sqrt(sum((xy_true).^2,2))) + abs(M-N)./N;
        elseif(M < N)
            c = mean(Diff(I)./sqrt(sum((xy_true(any(I,1),:)).^2,2))) + abs(M-N)./N;
        else
            c = mean(Diff(I)./sqrt(sum((xy_true).^2,2)));
        end
    elseif(isempty(xy_true) && ~isempty(xy_pred))
        c = M;
    elseif(~isempty(xy_true) && isempty(xy_pred))
        c = N;
    else
        c = 0;
    end
    cost = cost + c;
end
end

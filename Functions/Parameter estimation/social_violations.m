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
%                 Social Distance Violations Recognition
%
%  Syntax : [V, V_pos, D] = social_violations(xy, r)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% <INPUTs>
% xy : The ground positions in the video sequence as a cell array in the
%      real-world coordinates.
% r  : The social safety distance in meters.
%
% <OUTPUTs>
% V     : The social distance violations count in the video sequence.
% V_pos : The social distance violation positions in the video sequence as
%         a cell array.
% D     : The inter-personal distance matrix for the video sequence as a
%         cell array.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [V, V_pos, D] = social_violations(xy, r)
D = distance_matrix(xy);
V = zeros(1,length(D));
V_pos = cell(1,length(xy));
for i = 1:length(D)
    if(~isempty(D{i}))
        mask = triu(true(size(D{i})),1);
        D{i}(mask) = D{i}(mask) <= r;
        V(i) = sum(D{i},'all');
        if(V(i)>0)
            [Ir, Ic] = find(D{i}==1);
            V_pos{i} = xy{i}(unique([Ir; Ic]),:);
        else
            V_pos{i} = [];
        end
    else
        V(i) = 0;
        V_pos{i} = [];
    end
end

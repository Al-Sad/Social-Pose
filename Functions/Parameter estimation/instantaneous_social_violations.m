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
%          Instantaneous Social Distance Violations Recognition
%
%  Syntax : [V, D, Iv, In] = instantaneous_social_violations(xy, r)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% <INPUTs>
% xy : The instantaneous ground positions in the real-world coordinates.
% r  : The social safety distance in meters.
%
% <OUTPUTs>
% V  : The instantaneous social distance violations count.
% D  : The instantaneous inter-personal distance matrix.
% Iv : Index of the subjects that are r or less apart from each other.
% In : Index of the subjects that are more than r apart from each other.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [V, D, Iv, In] = instantaneous_social_violations(xy, r)
D = zeros(size(xy,1),size(xy,1));
for i = 1:size(xy,1)
    for j = 1:size(xy,1)
        D(i,j) = sqrt(sum((xy(i,:) - xy(j,:)).^2));
    end
end
In = 1:size(xy,1);
Dv = triu(D,1);
if(~isempty(Dv))
    mask = triu(true(size(Dv)),1);
    Ind = zeros(size(D));
    Ind(mask) = Dv(mask) <= r;
    V = sum(Dv,'all');
    if(V > 0)
        [Ivr, Ivc] = find(Ind == 1);
        Iv = unique([Ivr; Ivc]);
        In(Iv) = [];
    else
        Iv = [];
    end
else
    V = 0;
    Iv = [];
end
end
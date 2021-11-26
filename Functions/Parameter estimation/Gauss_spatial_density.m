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
%                    Symmetrical 2D Gaussian Function
%
%  Syntax : d = Gauss_spatial_density(u,r,x,y,Lx,Ly,N)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% <INPUTs>
% u  : The Gaussian center or mean.
% r  : The spatial resolution in meters.
% x  : The map x-coordinates.
% y  : The map y-coordinates.
% Lx : The map x-coordinates minimum and maximum.
% Ly : The map y-coordinates minimum and maximum.
% N  : The density mesh size (NxN).
%
% <OUTPUTs>
% d  : The Gaussian function centered at u with resolution r.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function d = Gauss_spatial_density(u,r,x,y,Lx,Ly,N)
s  = [r/2 r/2];
hx = 3*r;
hy = 3*r;
Gx = @(x)((Lx(2)-Lx(1)+2*hx)/((N-1)*sqrt(2*pi)*s(1)))*exp(-(x.^2)./(2*s(1)^2));
Gy = @(y)((Ly(2)-Ly(1)+2*hy)/((N-1)*sqrt(2*pi)*s(2)))*exp(-(y.^2)./(2*s(2)^2));
d = 0;
for i = 1:size(u,2)
    d = d + Gy(y-u(2,i))'*Gx(x-u(1,i));
end
d = d./size(u,2);
end

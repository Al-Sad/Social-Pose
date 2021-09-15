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
%                        Detection Adaptive Object
%
%  Syntax : detections = detections(gp,Ft,frame_cnt,noise_level)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% <INPUTs>
% gp          : The ground positions in the video sequence as a cell array
%               in the real-world coordinates.
% Ft          : Localization error flag for all positions in the video
%               sequence as a cell array.
% frame_cnt   : The frame number, or time index.
% noise_level : The three noise levels according to Ft.
%
% <OUTPUTs>
% detections : The appended detections with measurement noise.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function detections = detections(gp,Ft,frame_cnt,noise_level)
s1 = noise_level(1);
s2 = noise_level(2);
s3 = noise_level(3);
N  = size(gp,1);
detections = cell(N,1);
for i = 1:N
    switch Ft(i)
        case 0
            sn = s1;
        case 1
            sn = s2;
        case 2
            sn = s3;
    end
    measure_noise = [sn 0 ; 0 sn];
    detections{i} = objectDetection(frame_cnt,gp(i,:),'MeasurementNoise',measure_noise);
end
end

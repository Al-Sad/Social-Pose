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
%                  The Smoothing & Tracking Cost Function
%
%  Syntax : cost = kalman_opt_cost(xy_true, xy_est, Ft, opt_var, layout_xy)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% <INPUTs>
% xy_true   : The true ground positions in the video sequence as a cell
%             array in the real-world coordinates.
% xy_est    : The tracked ground positions in the video sequence as a cell
%             array in the real-world coordinates.
% Ft        : Localization error flag for all positions in the video
%             sequence as a cell array.
% opt_var   : The GNN tracker parameters to be optimized.
% layout_xy : The ROI layout in the real-world coordinates.
%
% <OUTPUTs>
% cost : The smoothing and tracking total cost to be minimized.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function cost = kalman_opt_cost(xy_true, xy_est, Ft, opt_var, layout_xy)
% Multi-Object tracking
Obj.Assignment            = 'Munkres';
Obj.TrackLogic            = 'Score';
Obj.AssignmentThreshold   = opt_var.AssignmentThreshold;
Obj.ConfirmationThreshold = opt_var.ConfirmationThreshold;
Obj.DeletionThreshold     = opt_var.DeletionThreshold;
Noise_level = [opt_var.noise_level_1 opt_var.noise_level_2 opt_var.noise_level_3];
xy_tracked = kalman_tracking(xy_est,Ft,Obj,Noise_level,layout_xy);
% Calculate tracking cost
V_pred = social_violations(xy_tracked, 1);
V_true = social_violations(xy_true, 1);
P = class_perf(V_true > 0, V_pred > 0);
cost = KF_distnace_cost(xy_true,xy_tracked) - 100.*mean(P);
end
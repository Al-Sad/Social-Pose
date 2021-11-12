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
%                   Kalman Filter Smoothing & Tracking
%
%  Syntax : [track_gp, track_gv] = kalman_tracking(gp,pf,Obj,noise_level,layout_xy)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% <INPUTs>
% gp          : The ground positions in the video sequence as a cell array
%               in the real-world coordinates.
% Ft          : Localization error flag for all positions in the video
%               sequence as a cell array.
% Obj         : The global nearest neighbor object containing its parameters.
% noise_level : The three noise levels according to Ft.
% layout_xy   : The ROI layout in the real-world coordinates.
%
% <OUTPUTs>
% track_gp : The smoothed and tracked ground positions in the video
%            sequence as a cell array in the real-world coordinates.
% track_gv : The smoothed and tracked ground velocities in the video
%            sequence as a cell array in the real-world coordinates.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [track_gp, track_gv] = kalman_tracking(gp,Ft,Obj,noise_level,layout_xy)
% Initialize parameters
num_frames = length(gp);
track_gp   = cell(1,num_frames);
track_gv   = cell(1,num_frames);
is_initial = 0;

% Initialize MOT-Tracker
tracker = initialize_GNN(Obj);

% Tracking and filtering
for i = 1:num_frames
    Detect_p = detections(gp{i},Ft{i},i,noise_level);
    if(~isempty(Detect_p) && ~is_initial)
        is_initial = 1;
    end
    if(is_initial)
        % update tracker       
        confirmedTracks = tracker(Detect_p,i);
        if(~isempty(confirmedTracks))
            % get updated position and velocity
            pos_track = get_data_id(confirmedTracks,[1 0 0 0; 0 0 1 0]);
            vel_track = sqrt(sum(get_data_id(confirmedTracks,[0 1 0 0; 0 0 0 1]).^2,2));
            % check if position is inside the ROI
            [IN, ON] = inpolygon(pos_track(:,1),pos_track(:,2),layout_xy(1,:),layout_xy(2,:));
            cond = IN & ~ON;
            % get filtered positions and velocities
            track_gp{i} = pos_track(cond,:);
            track_gv{i} = vel_track(cond,:);
            % apply the demotion condition
            Fcond = find(~cond);
            for j = 1:length(Fcond)
                confirmedTracks(Fcond(j)).IsConfirmed = 0;
            end
        end
    else
        track_gp{i} = [];
        track_gv{i} = [];
    end
end
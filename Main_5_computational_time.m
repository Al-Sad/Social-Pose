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
%
% Description:
% This main script produces the proposed system computational analysis
% results. It generates the system processing frame rate with and without
% the smoothing/tracking stage and saves the results in the "Computational
% Time" folder under "Data".

%% Initialization
clear; close all; clc;
addpath(genpath('Functions'));

%% Parameters
scene = '6p-c0';
K = 10;

%% Loading paths
% Pose estimation path
pose_estimation_path = ['Database\HumanJoints\' scene '.mat'];
% Calibration path
calibration_path = ['Database\Calibration\' scene '.mat'];
% Layout path
layout_path = ['Data\Layout\' scene '.mat'];
% Tracking parameters
GNN_path = ['Data\GNN Parameters\' scene '.mat'];

%% Saving Paths
% Computational time path
results_path = ['Data\Computational Time\' scene '.mat'];

%% Loading essential data
load(pose_estimation_path,'joints');
load(calibration_path);
load(layout_path);
num_frame = size(joints,2);

%% Loading the smoothing/tracking parameters
load(GNN_path);
Obj.Assignment = 'Munkres';
Obj.TrackLogic = 'Score';
Obj.AssignmentThreshold   = AssignmentThreshold;
Obj.ConfirmationThreshold = ConfirmationThreshold;
Obj.DeletionThreshold     = DeletionThreshold;
noise_level = [noise_level_1 noise_level_2 noise_level_3];

%% Initializing the density maps parameters
d  = 1;
N  = 256;
Lx = [min(layout_xy(1,:)) max(layout_xy(1,:))];
Ly = [min(layout_xy(2,:)) max(layout_xy(2,:))];
x  = linspace(Lx(1)-3,Lx(2)+3,N);
y  = linspace(Ly(1)-3,Ly(2)+3,N);
s  = [d/2 d/2];
hx = 3*d;
hy = 3*d;
Gx = @(x)((Lx(2)-Lx(1)+2*hx)/((N-1)*sqrt(2*pi)*s(1)))*exp(-(x.^2)./(2*s(1)^2));
Gy = @(y)((Ly(2)-Ly(1)+2*hy)/((N-1)*sqrt(2*pi)*s(2)))*exp(-(y.^2)./(2*s(2)^2));

%% Main
comp_time_proposed  = zeros(sum(~cellfun(@isempty,joints)),K);
num_people_proposed = zeros(sum(~cellfun(@isempty,joints)),K);
comp_time_tracked   = zeros(sum(~cellfun(@isempty,joints)),K);
num_people_tracked  = zeros(sum(~cellfun(@isempty,joints)),K);
for k = 1:K
    cnt1 = 0;
    cnt2 = 0;
    O_proposed = zeros(N,N);
    C_proposed = zeros(N,N);
    O_tracked  = zeros(N,N);
    C_tracked  = zeros(N,N);
    % Initializing the GNN tracker
    tracker = initialize_GNN(Obj);
    is_initial = 0;
    for i = 1:num_frame
        pose = joints{i};
        gp_uv = ground_position(pose,layout_uv);
        if(~isempty(gp_uv) && ~is_initial)
            is_initial = 1;
        end
        if(is_initial)
            %% First simulation (no tracking)
            tic;
            % Ground position estimation
            gp_uv = ground_position(pose,layout_uv);
            % Top-View transformation
            gp_xy = image2real(gp_uv,H,Scale);
            % Parameter estimation
            [V, ~, Iv, In] = instantaneous_social_violations(gp_xy, 2);
            tpv_xy = gp_xy(Iv,:); tpn_xy = gp_xy(In,:);
            Ctt_proposed = zeros(N,N); Ott_proposed = zeros(N,N);
            for j = 1:length(Iv)
                Ctt_proposed = Ctt_proposed + Gy(y-tpv_xy(j,2))'*Gx(x-tpv_xy(j,1));
            end
            for j = 1:length(In)
                Ott_proposed = Ott_proposed + Gy(y-tpn_xy(j,2))'*Gx(x-tpn_xy(j,1));
            end
            O_proposed = Ctt_proposed + Ott_proposed + O_proposed;
            C_proposed = Ctt_proposed + C_proposed;
            % Anomaly recognition
            St_proposed = V > 0;          
            if(sum(C_proposed,'all')>0)
                thr = linspace(0,max(C_proposed(:)),100);
                for q = 1:100
                    E = sum(C_proposed(C_proposed > thr(q)),'all')/sum(C_proposed,'all');
                    if(E <= 0.5)
                        break;
                    end
                end
                R_proposed = double(C_proposed > thr(q-1));
            else
                R_proposed = zeros(N,N);
            end
            % Get Processing time
            cnt1 = cnt1 + 1;
            comp_time_proposed(cnt1,k) = toc;
            num_people_proposed(cnt1,k) = size(gp_xy,1);
            
            %% Second simulation (with tracking)
            tic;
            % Ground position estimation
            [gp_uv, Ft] = ground_position(pose,layout_uv);
            % Top-View transformation
            gp_xy = image2real(gp_uv,H,Scale);
            % Check if any subject is detected
            Detect = detections(gp_xy,Ft,i,noise_level);
            % Smoothing and tracking
            tp_xy = smoothing_tracking(tracker,Detect,i,layout_xy);
            % Parameter estimation
            [V, D, Iv, In] = instantaneous_social_violations(tp_xy, 2);
            tpv_xy = tp_xy(Iv,:); tpn_xy = tp_xy(In,:);
            Ctt_tracked = zeros(N,N); Ott_tracked = zeros(N,N);
            for j = 1:length(Iv)
                Ctt_tracked = Ctt_tracked + Gy(y-tpv_xy(j,2))'*Gx(x-tpv_xy(j,1));
            end
            for j = 1:length(In)
                Ott_tracked = Ott_tracked + Gy(y-tpn_xy(j,2))'*Gx(x-tpn_xy(j,1));
            end
            O_tracked = Ctt_tracked + Ott_tracked + O_tracked;
            C_tracked = Ctt_tracked + C_tracked;
            % Anomaly recognition
            St_tracked = V > 0;          
            if(sum(C_tracked,'all')>0)
                thr = linspace(0,max(C_tracked(:)),100);
                for q = 1:100
                    E = sum(C_tracked(C_tracked > thr(q)),'all')/sum(C_tracked,'all');
                    if(E <= 0.5)
                        break;
                    end
                end
                R_tracked = double(C_tracked > thr(q-1));
            else
                R_tracked = zeros(N,N);
            end
            % Get Processing time
            cnt2 = cnt2 + 1;
            comp_time_tracked(cnt2,k) = toc;
            num_people_tracked(cnt2,k) = size(tp_xy,1);
        end
    end
    disp(k);
end

%% Saving
save(results_path,'comp_time_proposed','comp_time_tracked',...
    'num_people_proposed','num_people_tracked');

%% Functions
function [gp, Ft] = ground_position(pose,layout_uv)
if(~isempty(pose))
    L = size(pose,1);
    uv = zeros(L,2);
    Fu = zeros(L,1);
    Fv = zeros(L,1);
    cnt = 0;
    for j = 1:L
        cnt = cnt + 1;
        beta  = mean(pose(j,1,[12 23 24 25]),3,'omitnan');
        alpha = mean(pose(j,1,[15 20 21 22]),3,'omitnan');
        % Ground position x-coordinate estimation
        switch true
            case (all(~isnan([alpha beta])))
                u = mean([alpha beta]);
                Fu(cnt,1) = 1; % x coordinate is detected
            case (~isnan(alpha) && ~isnan(pose(j,1,11)))
                u = mean([alpha pose(j,1,11)]);
                Fu(cnt,1) = 2; % x coordinate is adjusted
            case (~isnan(pose(j,1,14)) && ~isnan(beta))
                u = mean([pose(j,1,14) beta]);
                Fu(cnt,1) = 2; % x coordinate is adjusted
            case (all(~isnan(pose(j,1,[11 14]))))
                u = mean(pose(j,1,[11 14]));
                Fu(cnt,1) = 2; % x coordinate is adjusted
            case (~isnan(pose(j,1,10)) && ~isnan(pose(j,1,14)))
                u = mean([pose(j,1,10) pose(j,1,14)]);
                Fu(cnt,1) = 2; % x coordinate is adjusted
            case (~isnan(pose(j,1,11)) && ~isnan(pose(j,1,13)))
                u = mean([pose(j,1,11) pose(j,1,13)]);
                Fu(cnt,1) = 2; % x coordinate is adjusted
            case (all(~isnan(pose(j,1,[10 13]))))
                u = mean(pose(j,1,[10 13]));
                Fu(cnt,1) = 2; % x coordinate is adjusted
            case (all(~isnan(pose(j,1,[2 9]))))
                u = mean(pose(j,1,[2 9]));
                Fu(cnt,1) = 2; % x coordinate is adjusted
            case (any(~isnan([alpha beta])))
                u = mean([alpha beta],2,'omitnan');
                Fu(cnt,1) = 2; % x coordinate is adjusted
            otherwise
                u = nan;
                Fu(cnt,1) = 0; % x coordinate is not detected
        end
        % Ground position y-coordinate checkup
        gamma = [mean(pose(j,2,[15 20 21 22]),3,'omitnan')...
            mean(pose(j,2,[12 23 24 25]),3,'omitnan')];
        % Ground position y-coordinate estimation
        switch true
            case(any(~isnan(gamma))) % this includes when both feets are detected
                v = mean(gamma,'omitnan');
                Fv(cnt,1) = 1; % y coordinate is detected
            case(all(~isnan(pose(j,2,[2 9]))))
                v = pose(j,2,9) + (0.85/0.6)*(abs(pose(j,2,2) - pose(j,2,9)));
                Fv(cnt,1) = 2; % y coordinate is detected
            otherwise
                v = nan;
                Fv(cnt,1) = 0; % y coordinate is not detected
        end
        % Ground position
        uv(cnt,:) = [u v];
    end
    uv = uv(~any(isnan(uv),2),:);
    gp = uv(inpolygon(uv(:,1),uv(:,2),layout_uv(1,:),layout_uv(2,:)),:);
    temp = Fu.*Fv;
    temp(temp > 2) = 2;
    Ft = temp;
else
    gp = [];
    Ft = [];
end
end
function gp_xy = image2real(gp_uv,H,s)
if(~isempty(gp_uv))
    u     = gp_uv(:,1);
    v     = gp_uv(:,2);
    uv    = [u'; v'; ones(1,length(u))];
    xyz   = H*uv;
    xyz   = xyz./xyz(3,:);
    gp_xy = (1/s).*xyz(1:2,:)';
else
    gp_xy = [];
end
end
function tp_xy = smoothing_tracking(tracker,Detect,i,layout_xy)
% update tracker
confirmedTracks = tracker(Detect,i);
if(~isempty(confirmedTracks))
    % get updated position
    pos_track = get_data_id(confirmedTracks,[1 0 0 0; 0 0 1 0]);
    % check if position is inside the ROI
    [IN, ON] = inpolygon(pos_track(:,1),pos_track(:,2),layout_xy(1,:),layout_xy(2,:));
    cond = IN & ~ON;
    % get filtered positions
    tp_xy = pos_track(cond,:);
    % apply the demotion condition
    Fcond = find(~cond);
    for j = 1:length(Fcond)
        confirmedTracks(Fcond(j)).IsConfirmed = 0;
    end
else
    tp_xy = [];
end
end
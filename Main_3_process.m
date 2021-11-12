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
% This main script executes and evaluates the proposed social distance
% estimation and crowd monitoring system stages.It localizes the human
% subjects, transforms their positions to the real-world coordinates,
% smooths/tracks the measurements, recognizes social distance violations,
% and identifies overcrowded regions. Besides it evaluates the system in
% terms of PDR, localization relative error, accuracy, F1-score, VCR, SSIM,
% CORR, and IOU. The localization, top-view transformation, and tracking
% results are saved in the "Ground Position Detections", "Top View Positions",
% and "Tracked Positions" folders under "Data", respectively. Additionally,
% the performance evaluations are saved in the "Performance Evaluation"
% folder under "Data".

%% Initialization
clear; close all; clc;
addpath(genpath('Functions'));

%% Parameters
scene = '6p-c0';

%% Loading paths
% Pose estimation path
pose_estimation_path = ['Database\HumanJoints\' scene '.mat'];
% Ground truth path
truth_path = ['Database\Annotation\' scene '.mat'];
% Calibration path
calibration_path = ['Database\Calibration\' scene '.mat'];
% Layout path
layout_path = ['Data\Layout\' scene '.mat'];
% Tracking parameters
GNN_path = ['Data\GNN Parameters\' scene '.mat'];

%% Saving Paths
% Ground position detection path
detection_path = ['Data\Ground Position Detections\' scene '.mat'];
% Top view position path
top_view_path = ['Data\Top View Positions\' scene '.mat'];
% Tracked positions path
tracked_path = ['Data\Tracked Positions\' scene '_mod.mat'];
% Performance evaluation path
results_path = ['Data\Performance Evaluation\' scene '.mat'];

%% Loading data
load(pose_estimation_path,'joints');
load(truth_path);
load(calibration_path);
load(layout_path);
load(GNN_path);

%% Ground position estimation
disp('Ground position estimation ...');
[gp_uv_basic_confirmed, gp_uv_basic_all] = basic_detector(joints,layout_uv);
[gp_uv_proposed_confirmed, gp_uv_proposed_all, Ft] = extended_detector(joints,layout_uv);
save(detection_path,'gp_uv_basic_confirmed','gp_uv_basic_all',...
    'gp_uv_proposed_confirmed','gp_uv_proposed_all','Ft');

%% Top-View transformation
disp('Top-View transformation ...');
gp_xy_basic_confirmed    = uv2xy(gp_uv_basic_confirmed,H,Scale);
gp_xy_basic_all          = uv2xy(gp_uv_basic_all,H,Scale);
gp_xy_proposed_confirmed = uv2xy(gp_uv_proposed_confirmed,H,Scale);
gp_xy_proposed_all       = uv2xy(gp_uv_proposed_all,H,Scale);
save(top_view_path,'gp_xy_basic_confirmed','gp_xy_basic_all',...
    'gp_xy_proposed_confirmed','gp_xy_proposed_all');

%% Smoothing and tracking
disp('Smoothing and tracking ...');
Obj.Assignment = 'Munkres';
Obj.TrackLogic = 'Score';
Obj.AssignmentThreshold   = AssignmentThreshold;
Obj.ConfirmationThreshold = ConfirmationThreshold;
Obj.DeletionThreshold     = DeletionThreshold;
noise_level = [noise_level_1 noise_level_2 noise_level_3];
gp_xy_tracked = kalman_tracking(gp_xy_proposed_all,Ft,Obj,noise_level,layout_xy);
gp_uv_tracked = xy2uv(gp_xy_tracked,H,Scale);
save(tracked_path,'gp_xy_tracked','gp_uv_tracked');

%% PDR and Localization error
disp('PDR and Localization error ...');
N_true       = count_people(gp_xy_true);
N_basic      = count_people(gp_xy_basic_confirmed);
N_proposed   = count_people(gp_xy_proposed_confirmed);
N_tracked    = count_people(gp_xy_tracked);
PDR_basic    = 1 - mean(abs(N_true - N_basic)./(N_true + 1));
PDR_proposed = 1 - mean(abs(N_true - N_proposed)./(N_true + 1));
PDR_tracked  = 1 - mean(abs(N_true - N_tracked)./(N_true + 1));
E_basic      = position_error(gp_xy_true, gp_xy_basic_confirmed);
E_proposed   = position_error(gp_xy_true, gp_xy_proposed_confirmed);
E_tracked    = position_error(gp_xy_true, gp_xy_tracked);
save(results_path,'PDR_basic','PDR_proposed','PDR_tracked',...
    'E_basic','E_proposed','E_tracked');

%% Social distance violations detection
disp('Social distance violations detection ...');
r            = linspace(1,2.5,31); % Social safety distance
P_basic      = zeros(length(r),2);
P_proposed   = zeros(length(r),2);
P_tracked    = zeros(length(r),2);
VCR_basic    = zeros(length(r),1);
VCR_proposed = zeros(length(r),1);
VCR_tracked  = zeros(length(r),1);
for i = 1:length(r)
    V_true          = social_violations(gp_xy_true,r(i));
    V_basic         = social_violations(gp_xy_basic_confirmed,r(i));
    V_proposed      = social_violations(gp_xy_proposed_confirmed,r(i));
    V_tracked       = social_violations(gp_xy_tracked,r(i));
    P_basic(i,:)    = class_perf(V_true > 0, V_basic > 0);
    P_proposed(i,:) = class_perf(V_true > 0, V_proposed > 0);
    P_tracked(i,:)  = class_perf(V_true > 0, V_tracked > 0);
    VCR_basic(i)    = 1 - mean(abs(V_true - V_basic)./(V_true + 1));
    VCR_proposed(i) = 1 - mean(abs(V_true - V_proposed)./(V_true + 1));
    VCR_tracked(i)  = 1 - mean(abs(V_true - V_tracked)./(V_true + 1));
end
save(results_path,'P_basic','P_proposed','P_tracked','VCR_basic',...
    'VCR_proposed','VCR_tracked','r','-append');

%% Overcrowded regions identification
disp('Overcrowded regions identification ...');
r             = linspace(1,2.5,31); % Social safety distance
N             = 512;                % The map number of samples NxN
d             = 1;                  % Spatial resolution
thresh        = 0.5;                % Energy threshold between 0 and 1
SSIM_basic    = zeros(length(r),1);
SSIM_proposed = zeros(length(r),1);
SSIM_tracked  = zeros(length(r),1);
CORR_basic    = zeros(length(r),1);
CORR_proposed = zeros(length(r),1);
CORR_tracked  = zeros(length(r),1);
IOU_basic     = zeros(length(r),1);
IOU_proposed  = zeros(length(r),1);
IOU_tracked   = zeros(length(r),1);
for i = 1:length(r)
    [~, Vp_true]             = social_violations(gp_xy_true,r(i));
    [~, Vp_basic]            = social_violations(gp_xy_basic_confirmed,r(i));
    [~, Vp_proposed]         = social_violations(gp_xy_proposed_confirmed,r(i));
    [~, Vp_tracked]          = social_violations(gp_xy_tracked,r(i));
    [R_true, D_true]         = density_map_thresh(Vp_true,layout_xy,d,thresh,N);
    [R_basic, D_basic]       = density_map_thresh(Vp_basic,layout_xy,d,thresh,N);
    [R_proposed, D_proposed] = density_map_thresh(Vp_proposed,layout_xy,d,thresh,N);
    [R_tracked, D_tracked]   = density_map_thresh(Vp_tracked,layout_xy,d,thresh,N);
    SSIM_basic(i)    = ssim(D_basic, D_true);
    SSIM_proposed(i) = ssim(D_proposed, D_true);
    SSIM_tracked(i)  = ssim(D_tracked, D_true);
    CORR_basic(i)    = corr(D_basic(:), D_true(:));
    CORR_proposed(i) = corr(D_proposed(:), D_true(:));
    CORR_tracked(i)  = corr(D_tracked(:), D_true(:));
    IOU_basic(i)     = sum(R_true & R_basic,'all')./sum(R_true | R_basic,'all');
    IOU_proposed(i)  = sum(R_true & R_proposed,'all')./sum(R_true | R_proposed,'all');
    IOU_tracked(i)   = sum(R_true & R_tracked,'all')./sum(R_true | R_tracked,'all');
end
save(results_path,'SSIM_basic','SSIM_proposed','SSIM_tracked',...
    'IOU_basic','IOU_proposed','IOU_tracked','CORR_basic',...
    'CORR_proposed','CORR_tracked','-append');
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
%
% Description:
% This main script optimizes the global nearest neighbor (GNN) tracking
% parameters. The optimization is initiated with the best-found solutions,
% executed for 500 iterations using the expected improvement plus acquisition
% function, and repeated five times for validation. The optimal parameters
% are then saved in the "GNN Parameters" folder under "Data".

%% Initialization
clear; close all; clc;
addpath(genpath('Functions'));

%% Parameters
scene = '6p-c0';

%% Main
disp_re = 1;   % 1 to display iterative results and 0 to hide
Use_par = 1;   % 1 to use parallel computing and 0 to use one CPU
N_iter  = 500; % Total number of iterations
K       = 5;   % Number of repetitions for validation
for k = 1:K
    %% Loading paths
    % Pose estimation path
    pose_estimation_path = ['Database\HumanJoints\' scene '.mat'];
    % Ground truth path
    truth_path = ['Database\Annotation\' scene '.mat'];
    % Calibration path
    calibration_path = ['Database\Calibration\' scene '.mat'];
    % Layout path
    layout_path = ['Data\Layout\' scene '.mat'];
    
    %% Saving paths
    % Tracking parameters
    parameters_path = ['Data\GNN Parameters\' scene '.mat'];
    
    %% Ground position estimation
    load(layout_path);
    load(pose_estimation_path,'joints');
    [~, gp_uv_proposed_all, Ft] = extended_detector(joints,layout_uv);
    
    %% Top-View transformation
    load(calibration_path);
    gp_xy_proposed_all = uv2xy(gp_uv_proposed_all,H,Scale);
    
    %% Bayesian optimization
    disp(['Round ' num2str(k)]);
    load(truth_path,'gp_xy_true');
    load(parameters_path);
    Initial_x = table(AssignmentThreshold, ConfirmationThreshold, ...
        DeletionThreshold, noise_level_1, noise_level_2, noise_level_3);
    opt_var(1) = optimizableVariable('AssignmentThreshold',[1 1e3],'Type','integer');
    opt_var(2) = optimizableVariable('ConfirmationThreshold',[1 1e3],'Type','integer');
    opt_var(3) = optimizableVariable('DeletionThreshold',[-200 -1],'Type','integer');
    opt_var(4) = optimizableVariable('noise_level_1',[1e-9 1e4],'Type','real','Transform', 'log');
    opt_var(5) = optimizableVariable('noise_level_2',[1e-9 1e4],'Type','real','Transform', 'log');
    opt_var(6) = optimizableVariable('noise_level_3',[1e-9 1e4],'Type','real','Transform', 'log');
    Fun = @(opt_var)kalman_opt_cost(gp_xy_true,gp_xy_proposed_all,Ft,opt_var,layout_xy);
    bayes_out = bayesopt(Fun,opt_var,'Verbose',disp_re,'UseParallel',Use_par,...
        'PlotFcn',[],'MaxObjectiveEvaluations',N_iter,...
        'AcquisitionFunctionName','expected-improvement-plus',...
        'IsObjectiveDeterministic',1,'InitialX',Initial_x);
    
    %% Saving optimized parameters
    Loss = bayes_out.ObjectiveMinimumTrace;
    AssignmentThreshold = bayes_out.XAtMinObjective.AssignmentThreshold;
    ConfirmationThreshold = bayes_out.XAtMinObjective.ConfirmationThreshold;
    DeletionThreshold = bayes_out.XAtMinObjective.DeletionThreshold;
    noise_level_1 = bayes_out.XAtMinObjective.noise_level_1;
    noise_level_2 = bayes_out.XAtMinObjective.noise_level_2;
    noise_level_3 = bayes_out.XAtMinObjective.noise_level_3;
    save(parameters_path,'AssignmentThreshold','ConfirmationThreshold',...
        'DeletionThreshold','noise_level_1','noise_level_2','noise_level_3','Loss');
end
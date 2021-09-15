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
% This demo script produces the results that are depicted in Fig. 7 of the
% paper. It generates the proposed system computational complexity analysis
% results in terms of frame rate grouped by the number of detected/tracked
% people in the scene.

%% Initialization
clear; close all; clc;
addpath(genpath('Functions'));

%% Load and collect results
time_path = 'Data\Computational Time\';
F = dir([time_path '/*.mat']);
T_total_proposed = [];
N_total_proposed = [];
T_total_tracked  = [];
N_total_tracked  = [];
for i = 1:length(F)
    load([time_path F(i).name]);
    T_total_proposed = cat(1,T_total_proposed,comp_time_proposed(2:end,:));
    N_total_proposed = cat(1,N_total_proposed,num_people_proposed(2:end,:));
    T_total_tracked  = cat(1,T_total_tracked,comp_time_tracked(2:end,:));
    N_total_tracked  = cat(1,N_total_tracked,num_people_tracked(2:end,:));
end
T_total_proposed = T_total_proposed(:);
N_total_proposed = N_total_proposed(:);
T_total_proposed = T_total_proposed(N_total_proposed > 0);
N_total_proposed = N_total_proposed(N_total_proposed > 0);
T_total_tracked = T_total_tracked(:);
N_total_tracked = N_total_tracked(:);
T_total_tracked = T_total_tracked(N_total_tracked > 0);
N_total_tracked = N_total_tracked(N_total_tracked > 0);

%% Arrange results
Num_proposed = unique(N_total_proposed);
Num_tracked  = unique(N_total_tracked);
md_proposed  = zeros(length(Num_proposed),1);
md_tracked   = zeros(length(Num_tracked),1);
for i = 1:length(Num_proposed)
    md_proposed(i) = median(1./T_total_proposed(N_total_proposed == Num_proposed(i)));
end
for i = 1:length(Num_tracked)
    md_tracked(i) = median(1./T_total_tracked(N_total_tracked == Num_tracked(i)));
end

%% Plotting
figure('Color',[1,1,1],'Position',[100 100 750 550]); hold on;
plot(-1:0.1:40,repelem(25,length(-1:0.1:40)),'k-','linewidth',1.5);
plot(-1:0.1:40,repelem(12,length(-1:0.1:40)),'k-.','linewidth',1.5);
plot(-1:0.1:40,repelem(5,length(-1:0.1:40)),'k:','linewidth',1.5);
plot(Num_proposed, md_proposed,'-b','linewidth',2);
plot(Num_tracked, md_tracked,'-r','linewidth',2);
plot(-1:0.1:40,repelem(mean(1./T_total_proposed),length(-1:0.1:40)),...
    'b--','linewidth',2);
plot(-1:0.1:40,repelem(mean(1./T_total_tracked),length(-1:0.1:40)),...
    'r--','linewidth',2);
boxchart(N_total_proposed,1./T_total_proposed,'MarkerStyle','none',...
    'BoxWidth',0.5,'BoxFaceColor','b','LineWidth',1.5);
boxchart(N_total_tracked,1./T_total_tracked,'MarkerStyle','none',...
    'BoxWidth',0.5,'BoxFaceColor','r','LineWidth',1.5);
legend('25 fps threshold','12 fps threshold','5 fps threshold',...
    'Proposed S/T: \times','Proposed S/T: \surd','Proposed S/T: \times (Average)',...
    'Proposed S/T: \surd (Average)','Orientation','vertical','NumColumns',2,...
    'Fontsize',16,'fontweight','bold','Box','off','location','northeast');
grid on; box on; axis([0.25 max(Num_tracked)+0.75 4 1.3e3]); xticks(1:4:max(Num_tracked));
xlabel('Number of detected/tracked people'); ylabel('Frames per second');
set(gca,'fontweight','bold','fontsize',24,'FontName','Times','Yscale','log');
set(gcf,'Units','inches'); screenposition = get(gcf,'Position');
set(gcf,'PaperPosition',[0 0 screenposition(3:4)],'PaperSize',screenposition(3:4));

%% Saving
opt = input('Do you want to save all main results (Y/N)\n','s');
if(opt == 'y' || opt == 'Y')
    print(1,'computation_time','-dpdf','-r400');
end
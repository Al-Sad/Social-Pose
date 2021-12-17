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
% Last Modification: 16-November-2021
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
T_total_proposed = T_total_proposed(N_total_proposed > 1);
N_total_proposed = N_total_proposed(N_total_proposed > 1);
T_total_tracked  = T_total_tracked(:);
N_total_tracked  = N_total_tracked(:);
T_total_tracked  = T_total_tracked(N_total_tracked > 1);
N_total_tracked  = N_total_tracked(N_total_tracked > 1);

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
boxchart(N_total_proposed,1./T_total_proposed,'MarkerStyle','none',...
    'BoxWidth',0.5,'BoxFaceColor','b','LineWidth',1.5);
plot(-1:0.1:40,repelem(mean(1./T_total_proposed),length(-1:0.1:40)),...
    'b-','linewidth',2);
legend('Proposed S/T: \times','Average','Orientation','vertical',...
    'Fontsize',25,'fontweight','bold','Box','off','location','northeast');
xticks(2:3:max(Num_proposed)); yticks(50:25:200);
grid on; box on; axis([1.25 max(Num_proposed)+0.75 50 200]);
xlabel('Number of detected people'); ylabel('Frames per second');
yv = get(gca,'YTick'); yyaxis right; yticks(yv); yticklabels(round(1000./yv));
axis([1.25 max(Num_proposed)+0.75 50 200]); ylabel('Milliseconds per frame');
set(gca,'fontweight','bold','fontsize',24,'FontName','Times','YColor','k');
set(gcf,'Units','inches'); screenposition = get(gcf,'Position');
set(gcf,'PaperPosition',[0 0 screenposition(3:4)],'PaperSize',screenposition(3:4));

figure('Color',[1,1,1],'Position',[100 100 750 550]); hold on;
boxchart(N_total_tracked,1./T_total_tracked,'MarkerStyle','none',...
    'BoxWidth',0.5,'BoxFaceColor','r','LineWidth',1.5);
plot(-1:0.1:40,repelem(mean(1./T_total_tracked),length(-1:0.1:40)),...
    'r-','linewidth',2);
legend('Proposed S/T: \surd','Average','Orientation','vertical',...
    'Fontsize',25,'fontweight','bold','Box','off','location','northeast');
xticks(2:3:max(Num_tracked)); yticks(5:10:75);
grid on; box on; axis([1.25 max(Num_tracked)+0.75 1 75]);
xlabel('Number of tracked people'); ylabel('Frames per second');
yv = get(gca,'YTick'); yyaxis right;
yticks(yv); yticklabels(round(1000./yv)); axis([1.25 max(Num_tracked)+0.75 1 75]);
ylabel('Milliseconds per frame');
set(gca,'fontweight','bold','fontsize',24,'FontName','Times','YColor','k');
set(gcf,'Units','inches'); screenposition = get(gcf,'Position');
set(gcf,'PaperPosition',[0 0 screenposition(3:4)],'PaperSize',screenposition(3:4));

%% Saving
opt = input('Do you want to save all main results (Y/N)\n','s');
if(opt == 'y' || opt == 'Y')
    print(1,'computation_time_proposed','-dpdf','-r400');
    print(2,'computation_time_tracked','-dpdf','-r400');
end
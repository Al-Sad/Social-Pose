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
% This demo script produces the results that are depicted in Table 2 and
% Fig. 6 of the paper. It generates the proposed system performance
% evaluation results in terms of PDR, localization relative error,
% accuracy, F1-score, VCR, SSIM, CORR, and IOU. In addition, it compares
% the proposed system with the basic approach.

%% Initialization
clear; close all; clc;
addpath(genpath('Functions'));

%% Parameters
disp_table = 0; % 0 to display in MATLAB style and 1 for LATEX

%% Weighted average coefficients according to the dataset number of frames
Total = 2954*4 + 4501 + 400*7;
c(1)  = 2954/Total;
c(2)  = 4501/Total;
c(3)  = 400/Total;

%% Load and collected the averaged performance evaluations
PDR_all  = zeros(3,12);
Err_all  = zeros(3,12);
Acc_all  = zeros(3,12);
F1s_all  = zeros(3,12);
VCR_all  = zeros(3,12);
SSIM_all = zeros(3,12);
CORR_all = zeros(3,12);
IOU_all  = zeros(3,12);
cnt = 0;
for i = 1:12
    if(i < 5)
        scene = ['6p-c' num2str(cnt)];
        cc = c(1);
    elseif(i == 5)
        scene = 'TownCentre';
        cnt = 0;
        cc = c(2);
    elseif(i > 5)
        scene = ['C' num2str(cnt)];
        cc = c(3);
    end
    cnt = cnt + 1;
    results_path = ['Data\Performance Evaluation\' scene '.mat'];
    load(results_path);
    PDR_all(:,i)  = [PDR_basic; PDR_proposed; PDR_tracked];
    Err_all(:,i)  = [E_basic; E_proposed; E_tracked];
    Acc_all(:,i)  = [mean(P_basic(:,1)); mean(P_proposed(:,1)); mean(P_tracked(:,1))];
    F1s_all(:,i)  = [mean(P_basic(:,2)); mean(P_proposed(:,2)); mean(P_tracked(:,2))];
    VCR_all(:,i)  = [mean(VCR_basic);  mean(VCR_proposed);  mean(VCR_tracked)];
    SSIM_all(:,i) = [mean(SSIM_basic); mean(SSIM_proposed); mean(SSIM_tracked)];
    CORR_all(:,i) = [mean(CORR_basic); mean(CORR_proposed); mean(CORR_tracked)];
    IOU_all(:,i)  = [mean(IOU_basic);  mean(IOU_proposed);  mean(IOU_tracked)];
end
Res_all = [PDR_all; Err_all; Acc_all; F1s_all; VCR_all; SSIM_all; CORR_all; IOU_all];
Overall = zeros(size(Res_all,1),1);
for i = 1:size(Res_all,1)
    Overall(i) = sum([c(1).*Res_all(i,1:4) c(2).*Res_all(i,5) c(3).*Res_all(i,6:12)]);
end
Out_all = 100.*[Res_all Overall];

%% Display performance results
switch disp_table
    case 0 % MATLAB style
        for i = 1:size(Out_all,1)
            for j = 1:size(Out_all,2)
                fprintf('%0.1f\t',round(Out_all(i,j),1));
            end
            fprintf('\n');
        end
    case 1 % LATEX style
        for i = 1:8
            st = (i-1)*3;
            if(i==1)
                fprintf('%s\n','\multirow{3}{*}{\textbf{PDR}}');
            elseif(i==2)
                fprintf('%s\n','\multirow{3}{*}{\textbf{Error}}');
            elseif(i==3)
                fprintf('%s\n','\multirow{3}{*}{\textbf{Accuracy}}');
            elseif(i==4)
                fprintf('%s\n','\multirow{3}{*}{\textbf{F1-score}}');
            elseif(i==5)
                fprintf('%s\n','\multirow{3}{*}{\textbf{VCR}}');
            elseif(i==6)
                fprintf('%s\n','\multirow{3}{*}{\textbf{SSIM}}');
            elseif(i==7)
                fprintf('%s\n','\multirow{3}{*}{\textbf{CORR}}');
            elseif(i==8)
                fprintf('%s\n','\multirow{3}{*}{\textbf{IOU}}');
            end
            
            for j = 1:3
                if(j==1)
                    fprintf('& Basic %s & %s','\cite{9423144}','-');
                elseif(j==2)
                    fprintf('& %s{Proposed} & %s','\multirow{2}{*}','\ding{53}');
                elseif(j==3)
                    fprintf('& & %s','\ding{51}');
                end
                for k = 1:size(Out_all,2)
                    fprintf(' & %0.1f',round(Out_all(st+j,k),1));
                end
                
                if(j==1)
                    fprintf('\n%s\n','\\\cline{2-16}');
                elseif(j==2)
                    fprintf('\n%s\n','\\\cline{3-16}');
                elseif(j==3 && i < 8)
                    fprintf('\n%s\n','\\\hhline{*{16}{-}}\multicolumn{16}{c}{}\\[-10pt]\hhline{*{16}{-}}');
                else
                    fprintf('\n%s\n','\\\cline{1-16}');
                end
            end
        end
end

%% Continuous performance evaluations
Perf_basic    = zeros(6,31);
Perf_proposed = zeros(6,31);
Perf_tracked  = zeros(6,31);
cnt = 0;
for i = 1:12
    if(i < 5)
        scene = ['6p-c' num2str(cnt)];
        cc = c(1);
    elseif(i == 5)
        scene = 'TownCentre';
        cnt = 0;
        cc = c(2);
    elseif(i > 5)
        scene = ['C' num2str(cnt)];
        cc = c(3);
    end
    cnt = cnt + 1;
    results_path = ['Data\Performance Evaluation\' scene '.mat'];
    load(results_path);
    Perf_basic = Perf_basic + cc.*[P_basic(:,1) P_basic(:,2)...
        VCR_basic SSIM_basic CORR_basic IOU_basic]';
    Perf_proposed = Perf_proposed + cc.*[P_proposed(:,1) P_proposed(:,2)...
        VCR_proposed SSIM_proposed CORR_proposed IOU_proposed]';
    Perf_tracked = Perf_tracked + cc.*[P_tracked(:,1) P_tracked(:,2)...
        VCR_tracked SSIM_tracked CORR_tracked IOU_tracked]';
end

figure('Color',[1,1,1],'Position',[100 100 700 550]);
p2 = plot(r,Perf_tracked(2,:),'-or','linewidth',3,'MarkerFaceColor','r'); hold on;
p1 = plot(r,Perf_tracked(1,:),'-db','linewidth',3);
p4 = plot(r,Perf_tracked(6,:),'-v','linewidth',3,...
    'Color',[0.31 0.73 0],'MarkerFaceColor',[0.31 0.73 0]);
p3 = plot(r,Perf_tracked(3,:),'-sk','linewidth',3,'MarkerFaceColor','k');
p6 = plot(r,Perf_basic(2,:),'-or','linewidth',1.5,'MarkerFaceColor','w');
p5 = plot(r,Perf_basic(1,:),'-db','linewidth',1.5);
p8 = plot(r,Perf_basic(6,:),'-v','linewidth',1.5,...
    'Color',[0.31 0.73 0],'MarkerFaceColor','w'); hold on;
p7 = plot(r,Perf_basic(3,:),'-sk','linewidth',1.5,'MarkerFaceColor','w');
grid on; xlabel('Social distance (m)');
ylim([0.55 0.98]); yticks(0.55:0.05:0.95);
legend([p1 p2 p3 p4 p5 p6 p7 p8],'Accuracy (Proposed)','F1-score (Proposed)',...
    'VCR (Proposed)','IOU (Proposed)','Accuracy (Basic)','F1-score (Basic)',...
    'VCR (Basic)','IOU (Basic)','NumColumns',2,'Fontsize',18,'fontweight',...
    'bold','Box','off','location','southeast');
set(gca,'fontweight','bold','fontsize',24,'FontName','Times');
set(gcf,'Units','inches'); screenposition = get(gcf,'Position');
set(gcf,'PaperPosition',[0 0 screenposition(3:4)],'PaperSize',screenposition(3:4));

%% Saving
opt = input('Do you want to save all main results (Y/N)\n','s');
if(opt == 'y' || opt == 'Y')
    print(1,'perf_evaluation','-dpdf','-r400');
end
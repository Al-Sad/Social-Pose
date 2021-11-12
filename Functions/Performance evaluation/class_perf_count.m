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
%               Generalized Classification Performance Counts
%
%  Syntax : [TP, TN, FP, FN] = class_perf_count(label_true,label_pred)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
% <INPUTs>
% label_true : The true classification label(s).
% label_pred : The predicted classification label(s).
%
% <OUTPUTs>
% TP : True positives.
% TN : True negatives.
% FP : False positives.
% FN : False negatives.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

function [TP, TN, FP, FN] = class_perf_count(label_true,label_pred)
Classes = unique(label_true);
N_class = length(Classes);
if(N_class > 2)
    TP = zeros(N_class,1);
    TN = zeros(N_class,1);
    FP = zeros(N_class,1);
    FN = zeros(N_class,1);
    for i = 1:N_class
        TP(i) = sum( (label_pred == Classes(i)) & (label_true == Classes(i)) );
        FP(i) = sum( (label_pred == Classes(i)) & (label_true ~= Classes(i)) );
        FN(i) = sum( (label_pred ~= Classes(i)) & (label_true == Classes(i)) );
        TN(i) = sum( (label_pred ~= Classes(i)) & (label_true ~= Classes(i)) );
    end
else
    TP = sum( (label_pred == 1) & (label_true == 1) );
    FP = sum( (label_pred == 1) & (label_true ~= 1) );
    FN = sum( (label_pred ~= 1) & (label_true == 1) );
    TN = sum( (label_pred ~= 1) & (label_true ~= 1) );
end
end

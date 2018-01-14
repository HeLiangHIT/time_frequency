function [linesInfo,errInfo] = curveModify(lines,N,stretch)
%% 修复和检测提取的曲线信息，主要修复如下两方面的问题：
% 1）曲线端点的分岔问题，将其两个分岔求均值作为曲线的真值。
% 2）垂直方向连着的曲线问题，主要是其拟合的直线和正弦曲线都无法完美的满足误差需求，因此可以将其丢弃
% 输出：linesInfo，结构体cell，包含成员line表示各个分量的线段信息；type表示该分量的类型，
% 输入：N表示采样点数

warning off;%关闭拟合时的提示
% stretch = 1;%两端延长：LLS信号设置为15可以恢复

linesInfo = {};%空cell
errInfo = {};
for k=1:length(lines)
    line = lines{k};%提取出该行曲线
    %[~,ind] = sort(line(:,1));line = line(ind,:);   %按照横轴排序，plot(line(:,1),line(:,2),'.-');hold on
    %% 修复line里面的分岔和交叠错误
    
    
    x_min = max([min(line(:,1))-stretch,1]); x_max = min([max(line(:,1))+stretch,N]);
    x = x_min:x_max;%横坐标--不用延长【可以左右延迟winLen长度较好】
    %% 直线和正弦曲线拟合并判断误差：注意分岔处的误差
    [fitreL, gofL] = linFit(line(:,1), line(:,2));%plot(x,fitreL(x),'kx-')
    [fitreS, gofS] = sinFit(line(:,1), line(:,2));%plot(x,fitreS(x),'r+-')
    resMax = 20*length(line);%误差不能超过5*长度，这里考虑到轮廓*2，重叠部分*2，最大就*4而已。
    
    %% 交叉等错误曲线的修正
    if gofS.sse>resMax && gofL.sse>resMax %Sum of squares due to error
        fprintf('曲线%d类型未识别，待处理！！！\n',k);
        %% 输出用于分析错误原因
        errInfo{end+1} = line;
        continue;
    end
    
    %% 根据拟合误差判断曲线是直线还是SIN曲线
    if gofL.sse<gofS.sse || isnan(gofL.sse) %2个点的时候LIN可以通过但是sse是nan
        line = [x',fitreL(x)];
        type = 'lin';%'sin', 'line','undefined'
        fun = fitreL;%拟合系数
    else
        line = [x',fitreS(x)];
        type = 'sin';%'sin', 'line','undefined'
        fun = fitreS;%拟合系数
    end
    linesInfo{end+1} = struct('line', line, ...%曲线满足要求的情况下这么做
        'type', type,...
        'fun', fun);%'sin', 'line','undefined'
end

%% 调试语句
% for k = 1:length(linesInfo)
%     plot(linesInfo{k}.line(:,1),linesInfo{k}.line(:,2),'.-');hold on; 
% end
end

function [fitresult, gof] = sinFit(x, y)
%CREATEFIT(X,Y):cftool
%  Create a fit.
%  Data for 'mySin' fit:
%      X Input : x
%      Y Output: y
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%  另请参阅 FIT, CFIT, SFIT.

%% Fit: 'mySin'.
[xData, yData] = prepareCurveData( x, y );
% Set up fittype and options.
ft = fittype( 'fourier2' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf -Inf -Inf -Inf 0.01];%限制正弦曲线拟合的频率下界，如果下界太小可能拟合到直线
opts.StartPoint = [0 0 0 0 0 0.02];%【初值很重要！需要大概正确才行！】
opts.Upper = [Inf Inf Inf Inf Inf pi];
% Fit model to data.
try
    [fitresult, gof] = fit( xData, yData, ft, opts );
catch
    fitresult = [];gof.sse = inf;
end
    
end

function [fitresult, gof] = linFit(x, y)
%CREATEFIT(X,Y)
%  Data for 'linFit' fit:
%      X Input : x
%      Y Output: y
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%  另请参阅 FIT, CFIT, SFIT.

%% Fit: 'linFit'.
[xData, yData] = prepareCurveData( x, y );
% Set up fittype and options.
ft = fittype( 'poly1' );
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Robust = 'Bisquare';
% Fit model to data.
try
    [fitresult, gof] = fit( xData, yData, ft, opts );
catch
    fitresult = [];gof.sse = inf;
end

end



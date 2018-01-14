function sigs_o = amplitudeFit(sigs, tfr, tfrv, edgeLen)
%% sigs_o = amplitudeFit(sigs, tfr, tfrv, edgeLen) 根据输入的各个分量信号sigs和相应滤波前后谱重建信号sigs_o
% 输入：
%       sigs： 结构体数组，表示多个分量的信号
%       tfr : 信号的完整时频分布
%       tfrv： 时变滤波输出的滤波后分布
%       edgeLen：边缘幅度衰变的长度，通常建议为STFT时变滤波求TFR窗长度的1/4
% 输出：sigs_o和输入sigs一样的含义，但是修复了幅度叠加的地方

[tLen,sigN] = size(sigs);%长度确定
t = 1:tLen; %时刻点
sigs_o = zeros(size(sigs));% 信号初始化
oTfr = sum(tfrv,3) - tfr.*(sum(abs(tfrv),3)~=0); %交叉处的位置

% 信号畸变的修正
for k = 1:sigN%对各个信号
    %x = hilbert(sigs(:,k));%第k个分量的信号，希尔伯特变换获取信号瞬时幅度
    %其实信号本身就是一个复数信号，无需希尔伯特变换直接abs就是信号的幅度。因此直接拟合幅度就行了。
    x_abs = abs(sigs(:,k));%分量信号的幅度
    % 计算各个信号叠加部分的幅值
    [r,c] = find(oTfr~=0);%找到交叉分量不为0的地方
    oTfrk = zeros(size(tfr));    oTfrk(r,c) = tfrv(r,c,k);%取分量k存在于交叉分量地方的值
    overlays = sum(abs(oTfrk),1);%计算各个时刻的叠加幅度值
    %imagesc(abs(oTfrk));axis xy;figure;plot(overlays);axis tight
    cor_index = find(overlays==0);%找到交叉点之外的数据作为插值已知点
    if length(cor_index)< 3; sigs_o(:,k) = sigs(:,k); break; end
    if length(cor_index) > 2* edgeLen;%满足超过长度的情况下才可以插值，否则只能取其中间两个值
        %cor_index = cor_index(edgeLen:end - edgeLen);%去除边缘部分的值，后面再插值即可
        x_abs(1:edgeLen) = x_abs(edgeLen);   x_abs(end - edgeLen:end) = x_abs(edgeLen);%边缘无法插值，只能直接取值
    end
    try %尝试拟合，此处发现拟合只能针对SIN调幅进行，需要拟合样式的定义，不通用。
        [fitreS, gofS] = sinFit(cor_index, x_abs(cor_index));%gofS.sse反应拟合效果
        x_abs_hat = fitreS(t);%拟合的方式获取% plot(t,x_abs_hat,'k.-')
        assert(gofS.sse.^2<std(x_abs),'fit error!');%这个阈值很难处理和选择
    catch
        x_abs_hat = interp1(cor_index,x_abs(cor_index),t,'linear');%线性插值是最好的方式 linear ,
        x_abs_hat = filterAbs(x_abs_hat,20)'; %平滑处理% plot(t,x_abs_hat,'k.-')
    end
    sigs_o(:,k) = sigs(:,k)./x_abs.*x_abs_hat;%幅度调制
end





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

warning('off','iWarnIfSizeMismatch');%关闭该警告

%% Fit: 'mySin'.
[xData, yData] = prepareCurveData( x, y );
% Set up fittype and options.
ft = fittype( 'fourier1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf -Inf 0];%最后一个是w的范围
opts.StartPoint = [0 0 0 0.05];
opts.Upper = [Inf Inf Inf pi];
% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

end




function abs_smooth=filterAbs(x,winLen)
%---------------------------------------------------------------------
% filter IF law by convolving with Hamming window
%---------------------------------------------------------------------
if(nargin<2 || isempty(winLen)) winLen=15; end

w=hamming( floor(winLen) ); w=w./sum(w);

abs_mean=mean(x);
abs_smooth=conv(x-abs_mean,w,'same');
abs_smooth=abs_smooth+abs_mean;

end

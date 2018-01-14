function s_hat = stfrftTvf_1Cmpnt(sn)
%% 针对单分量FM信号的分数阶时变滤波，必须针对单分量才能调用本函数。
% 依赖：时频分析工具箱 TFSAP
% 注意：输入信号必须为连续FM（不能是跳频）。
% 输入：sn为实数信号，含噪声和干扰等。
% 输出：s_hat为重建的FM信号

fftLen = 128; % IF估计窗长度

% 信号初始化准备
s = hilbert(sn(:));%转换为解析信号
ifs = zce( s, fftLen);% 瞬时频率估计TFSAP %plot(ifs)
ifsFix = filterIfs(ifs);%平滑IF信息 % plot(ifsFix)
ifsFit = linFit(ifsFix); % 拟合IF直线 % plot(ifsFit)
% t = 1:length(ifsFit);plot(t,ifs,'b',t,ifsFix,'k',t,ifsFit,'r');legend('zce','fix','fit');

% 信号重建
[s_hat,tfr,tfrv ]= stfrft_rec(s,ifsFit,8);%重建
% figure;subplot(121);imagesc(abs(tfr)); axis xy; 
% subplot(122);imagesc(abs(tfrv)); axis xy; 

s_hat = reshape(s_hat,size(sn,1),size(sn,2));%保持信号尺寸不变



end

function y = linFit(x)
% 直线拟合
t = [1:length(x)]';
[xData, yData] = prepareCurveData( t, x );
ft = fittype( 'poly1' );
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Robust = 'Bisquare';
[fitresult, gof] = fit( xData, yData, ft, opts );
y = fitresult(t);
end


function y=filterIfs(x,winLen)
% 对IF信息进行平滑
if(nargin<2 || isempty(winLen)) winLen=15; end
w=hamming( floor(winLen) ); w=w./sum(w);
abs_mean=mean(x);
y=conv(x-abs_mean,w,'same');
y=y+abs_mean;
% 将两端的IF信息采用边缘填充的方法，避免ZCE估计的IF信息边缘
y = [ones(winLen,1)*y(winLen+1);
    y(winLen+1 : end - winLen);
    ones(winLen,1)*y(end - winLen)];

end


function [sigs,tfr,tfrv,ucs] = stfrft_rec(x,ifs,halfLen,h)
%% 基于短时傅立叶变换时变滤波的信号分离，自适应窗长度：[sigs,tfr,tfrv] = stfrft_rec(x,ifs,halfLen,h)
% 输入：x：输入信号，是多个分量的叠加
%           ifs：各列是各个分量的瞬时频率，
%           halLen：固定窗长度的窗半长度
%           h：可选一行或者一列输入的窗函数，需要注意h(0)=1，否则无法恢复信号。
% 输出：sigs：输出信号，各列表示一个信号
%           tfr：三维矩阵分别表示各个分量的STFRFT谱
%           tfrv：三维矩阵分别表示各个分量的STFRFT谱
%           ucs：STDRFT谱中各个横轴对应的频率值

% 可调节的参数
thr = 0.2;%时变滤波的限定值【和噪声有关，且值越大信号的幅度衰减越大，需要将幅度根据这个值补回来】

assert(nargin>=2,'At least 2 parameter is required.');
% 时变滤波时重复边缘的宏控制，为了避免时变滤波边缘衰变设置该参数，可选设置为1或者0
EDGE_REPEAT = 1;%

%参数初始化
x = x(:);   tLen = length(x);  t=1:tLen; %获取时间长度
fLen = min([tLen, 512]);%频域最大分辨率为512
[tmp,sigN] = size(ifs);%获取信号的数量
assert(tmp ==  tLen,'Input Length of s must be same as ifs.');%错误判断
if ( nargin < 3),
    halfLen = min([fLen, 30]);%时变滤波的最大窗口长度的一半
end
assert(halfLen<length(x)/2,'The max window length must be small than signal length.');
if nargin < 4,
    hlength=floor(fLen/4); hlength=hlength+1-rem(hlength,2); 
    h = tftb_window(hlength);%默认是Hamming
end
% h=h/norm(h);%保证h(0)=1，才能恢复信号
h = h(:); hrow=length(h); Lh=(hrow-1)/2;%窗参数
if (rem(hrow,2)==0),  error('H must be a smoothing window with odd length.');end

% 计算旋转阶数和对应FRFT域频率
ps = zeros(size(ifs)); ucs = zeros(size(ifs));
for is = 1:sigN
    [~,uc,p] = fftIflaw2frftIflaw(ifs(:,is),fLen);
    %这里最好修正一下频率值为nan的地方，要么设置其为0要么设置其为最近的非nan值
    ucs(:,is) = mod(round(uc),fLen)+1;%uc作为下标必须为整数
    ps(:,is) = p;
end


tfr= zeros(fLen,tLen,sigN) ;midN = round(fLen/2);% TFR参数初始化
sigs = zeros(tLen,sigN);tfrv = zeros(fLen,tLen,sigN) ;
for it=1:tLen,
    ti= t(it); tau=max([-midN+1,-Lh,-ti+1]):min([midN-1,Lh,tLen-ti]);
    if EDGE_REPEAT
        %taux = [tau(1)*ones(1,tau(end) - abs(tau(1))),tau,tau(end)*ones(1,abs(tau(1))-tau(end))];%重复边缘为边缘值
        taux = [zeros(1,tau(end) - abs(tau(1))), tau,zeros(1,abs(tau(1))-tau(end))];%重复边缘为当前值
        tauh = 1:hrow;%全部重复
        indices= (midN-Lh) : (midN + Lh);%值重复保存
    else
        taux = tau;
        tauh = Lh+1+tau;
        indices= rem(midN+tau-1,fLen)+1;
    end
    % 计算原始STFRFT
    stmp = zeros(tLen,1);
    stmp(indices)=x(ti+taux,1).*conj(h(tauh));
    %对各个信号时变滤波
    for is = 1:sigN
        %该时刻频谱的滤波
        tfr(:,it,is)=frft(stmp,ps(it,is));%计算FFT谱，对每个时刻
        ftfr = tvfIter(tfr(:,it,is), ucs(it,is), thr, halfLen);%频域滤波，频域的矩形窗。适当放宽限制。
        %信号时域值恢复
        st = ifrft(ftfr,ps(it,is));%滤波后的数据反变换
        sigs(it,is) = st(midN);%加入的数据是中间值，滤波恢复的也得是中间值
        %plot(t,real(stmp),'b.-',t,real(st),'r.-')%调试信号
        tfrv(:,it,is) = ftfr;
        % 修正旋转跳变
        if ps(it,is)<0
            tfr(1:fLen,it,is) = tfr(fLen:-1:1,it,is);%将其校正为正确的值范围
            tfrv(1:fLen,it,is) = tfrv(fLen:-1:1,it,is);
            ucs(it,is) = fLen - ucs(it,is);%返回校正后的真是STFRFT频率
        end
    end
end

end


function y = tvfIter(x, ind, thr, maxLen)
% 对输入的频域数据x，从ind处往两边延伸查找到峰值边界，之后将其它数据归0。
% 边界的定义：其幅值小于阈值edgeThr*max且是极小值的点。如果查找到的极值点超过maxLen则放弃。
edgeThr = 0.4; %边缘
Len = length(x);
y = zeros(size(x));%默认都是0
y(ind) = x(ind); maxAbs = abs(x(ind));%计算最大值
%% 往前搜索
absp = maxAbs;
for len = 0:maxLen %注意需要包含0长度点
    indc = mod(ind-len,Len) + 1; %往左边找
    absc = abs(x(indc));
    if maxAbs<absc; maxAbs = absc; end
    if (absc < maxAbs*thr); break; end %到达阈值
    if (absc < maxAbs * edgeThr) && (absc > absp); break;  end%边界到达条件
    y(indc) = x(indc);%本节点包含到滤波后的数据
    absp = absc; %记录本节点的幅值
end
%% 往后搜索
absp = maxAbs;
for len = 0:maxLen 
    indc = mod(ind+len,Len) + 1; %往右边找
    absc = abs(x(indc));
    if maxAbs<absc; maxAbs = absc; end
    if (absc < maxAbs*thr); break; end %到达阈值
    if (absc < maxAbs * edgeThr) && (absc > absp); break;  end%边界到达条件，主要是为了抑制交叉分量
    y(indc) = x(indc);%本节点包含到滤波后的数据
    absp = absc; %记录本节点的幅值
end

end


function [fc,uc,popt] = fftIflaw2frftIflaw(iflaw,fLen)
% [fc,uc,popt] = fftIflaw2frftIflaw(iflaw,fLen)
%% 把STFT变换的瞬时频率iflaw转换为STFRFT变换的瞬时频率
% 输入iflaw是信号的瞬时频率，fLen是其频率采样点数量
% 输出fc表示信号的瞬时频率，uc表示信号的瞬时分数阶频率，popt是各个点的FRFT最佳阶数
% 需要注意的是这里返回的fc和uc都是理想的频率坐标点，要使用需要将其【取四舍五入】

if max(iflaw)>0.5 %这种情况表明iflaw是整数频率点，先将其归一化到实际数字频率点
    if max(iflaw)>1; iflaw = iflaw/fLen; end
    iflaw(iflaw>0.5) = iflaw(iflaw>0.5)-1;
end

% 根据iflaw获取斜率，进而得到FRFT旋转角度
kgen = diff(iflaw);% IF的导数是斜率k
% kgenl = [kgen(1);kgen];kgenr = [kgen;kgen(end)];
% kgen = (kgenl+kgenr)/2;
%某一个点的斜率是其左斜率和右斜率的均值，其实可以只取kgenl也影响不大。
popt = real(-acot(kgen*fLen)*2/pi);
% poptl = [popt(1);popt];poptr = [popt;popt(end)];
% popt = (poptl+poptr)/2;
popt = [popt(1);popt];%我也不知道为什么，反正这样出错的概率最小

% 根据实际频率点以及相对偏移值
fc = real(iflaw*fLen); 
uc = real(iflaw*fLen .* sin(popt*pi/2));%实际FRFT域频率


end



function y = frft(x, p, N)
% 修正：1）可以自定义变换长度，~2）让其缩放与FFT效果相同~
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fractional Fourier Transform
%	frac_x = fracft(x, theta) with scale of sqrt(length(x))
%	x      : Signal under analysis，信号长度最好为偶数，否则变换不可逆。
%	theta  : Fractional Angle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3; N = length(x); end

x = [x(:); zeros(N-length(x),1)];
y = fracft(x,p);
% y = frft_org(x,p);
y = y * sqrt(N);%缩放恢复
y = fftshift(y);%位移恢复
% M = floor(N/2);
% y = [y(M+1:N); y(1:M)];

end

function y = ifrft(x, p, N)
% 修正：1）可以自定义变换长度，~2）让其缩放与FFT效果相同~
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inverse Fractional Fourier Transform
%	y = ifrft(x, p, N)
%	x  : Signal under analysis，信号长度最好为偶数，否则变换不可逆。
%	p  : Fractional Angle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3; N = length(x); end

x = x / sqrt(N);%缩放恢复
x = fftshift(x);%位移恢复
% y = frft_org(x,-p);
y = fracft(x,-p);
y = y(1:N);

end


function frac_x = fracft(x, theta)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fractional Fourier Transform
%	frac_x = fracft(x, theta) with scale of sqrt(length(x))
% 
%	x      : Signal under analysis
%	theta  : Fractional Angle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Main Program
N = length(x); M = floor(N/2);
theta = mod(theta,4);
if (theta==0)
  frac_x = x;
  return
elseif (theta==1)
  frac_x = fft([x(M+1:N); x(1:M)])/sqrt(N);
  frac_x = [frac_x(M+2:N); frac_x(1:M+1)]; % [[[--a sample delay related to fft--]]]
  return
elseif (theta==2)
  frac_x = flipud(x);
  return
elseif (theta==3)
  frac_x = ifft([x(M+1:N); x(1:M)])*sqrt(N);
  frac_x = [frac_x(M+2:N); frac_x(1:M+1)];
  return
end
if (theta > 2)
  x = flipud(x);
  theta = theta - 2;
end
if (theta > 1.5)
  x = fft([x(M+1:N); x(1:M)])/sqrt(N);
  x = [x(M+2:N); x(1:M+1)];
  theta = theta - 1;
end
if (theta < 0.5)
  x = ifft([x(M+1:N); x(1:M)])*sqrt(N);
  x = [x(M+2:N); x(1:M+1)];
  theta = theta + 1;
end

%% Interpolation using Sinc
P = 3;
x = interp_sinc(x, P);
x = [zeros(2*M,1) ; x ; zeros(2*M,1)];

%% Axis Shearing
phi   = theta*pi/2;
alpha = cot(phi);
beta  = csc(phi);
%%% First: Frequency Shear
c = 2*pi/N*(alpha-beta)/P^2;
NN = length(x); MM = (NN-1)/2; n = (-MM:MM)';
x2 = x.*exp(1i*c/2*n.^2);
% %%% Second: Time Shear
c = 2*pi/N*beta/P^2;
NN = length(x2); MM = (NN-1)/2;
interp = ceil(2*abs(c)/(2*pi/NN));
xx = interp_sinc(x2,interp)/interp;
n = (-2*MM:1/interp:2*MM)';
h = exp(1i*c/2*n.^2);
x3 = conv(xx, h, 'same');
if (isreal(xx) && isreal(h)); x3 = real(x3); end
center = (length(x3)+1)/2;
x3 = x3(center-interp*MM:interp:center+interp*MM);
x3 = x3*sqrt(c/2/pi);
%%% Third: Frequency Shear
c =  2*pi/N*(alpha-beta)/P^2;
NN = length(x3); MM = (NN-1)/2; n = (-MM:MM)';
frac_x = x3.*exp(1i*c/2*n.^2);

%% Output Signal
frac_x = frac_x(2*M+1:end-2*M);
frac_x = frac_x(1:P:end);
frac_x = exp(-1i*(pi*sign(sin(phi))/4-phi/2))*frac_x;



end

function x_r = interp_sinc(x, a)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Interpolation using anti-aliasing filter (Sinc Interpolation)
% x_r = interp_sinc(x, a)
% 
% x      : Signal under analysis
% a      : Resample ratio, equivalent to P/Q in the built in function
%         "resample"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%
N = length(x);       % Original number samples
M = a*N - a + 1;     % New number of samples
temp1 = zeros(M,1);  %
temp1(1:a:M) = x;    % Adding a-1 zeros between samples

%% Creating the Sinc function
n = -(N-1-1/a):1/a:(N-1-1/a); h = sinc(n(:));

%% Filtering in the Frequency Domain
x_r = conv(temp1, h, 'same');
if (isreal(temp1) && isreal(h)); x_r = real(x_r); end
end



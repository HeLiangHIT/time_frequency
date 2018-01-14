function [y,tfr] = tfpf_iter(s, maxf)
%% 一次时频峰值滤波迭代操作，
% 原理参考： Boashash B, Mesbah M. Signal enhancement by time-frequency peak filtering [J]. IEEE Transactions on Signal Processing, 2004, 52(4): 929-37.
% 以及：Rankine L, Mesbah M, Boashash B. IF estimation for multicomponent signals using image processing techniques in the time–frequency domain [J]. Signal Process, 2007, 87(6): 1234-50.
% 输入：
% s : 输入信号，必须是实数信号
% maxf：输入信号的最大数字频率fmax/Fs，该参数和PWVD的延迟窗长度关系很大。

s = s(:);
if nargin < 2; maxf = 0.05; end
%% 参数获取和初始化
UpSampling = 1/maxf;%升采样倍数，其实就是采样频率是信号最大频率的倍数
WinLen = floor(1.28*UpSampling/pi) - 1;%时延窗长度，有计算公式，和UpSampling有关系
WinLen = WinLen + (~mod(WinLen,2));%必须是奇数
if WinLen<3; WinLen = 3; end
% 信号的增强效果和WinLen长度相关性非常大！！！！！
GuardEdge = WinLen * 2;%信号的两边扩展

FreqLen = 512;%频域采样点数
Miu = 0.9;%IF信息缩放，1表示0-0.5范围内
h=ones(WinLen,1);%PWVD的窗函数，暂时选择矩形窗
guard = ones(GuardEdge,1);%边缘保护

%% 复数信号产生
% 信号升采样
% sr = resample(s,UpSampling,1);%升采样函数%plot(sr,'.-');axis tight;
sr = [guard*s(1);s;guard*s(end)];%升采样是采样时的物理操作，不是这个算法的一部分！！
% 如果把升采样和降采样都放进算法里面来，就起不到信号增强的效果，因为噪声也在这里升采样时被平滑了。
maxValue = max(sr(:));
minValue = min(sr(:));
% 信号归一化并合成解析信号
x = (sr - minValue)/(maxValue-minValue)*0.3+0.1;%信号线性缩放到0.1-0.4之间
sc = cumsum(x);%累加和%plot(sc)
z = exp(1j * 2 * pi * Miu * sc);%产生复数信号z

%% PWVD峰值IF估计
[tfr,~,~]=tfrpwv(z,1:length(z),FreqLen,h);
% figure;[tfr,T,F]=tfrwv(z,1:length(z),FreqLen);
% subplot(4,1,1:3);imagesc(tfr); subplot(4,1,4);plot(sr); axis tight
% figure;[tfr,T,F]=tfrpwv(z,1:length(z),FreqLen,h);
% subplot(4,1,1:3);imagesc(tfr); subplot(4,1,4);plot(sr); axis tight
[~,flaw]=max(tfr);%查找峰值对应的IF值
flaw = flaw/FreqLen/2;%归一化到0-0.5之间
ye = (flaw/Miu - 0.1) * (maxValue-minValue)/0.3 + minValue;%反变换回去到原始信号幅度

% 信号降采样
% y = resample(ye,1,UpSampling);%信号降采样
y = ye((GuardEdge+1):(end - GuardEdge));
tfr = tfr(:,(GuardEdge+1):(end - GuardEdge));
% t = 1:length(s); plot(t,s,'bx-',t,y,'r.-');



end
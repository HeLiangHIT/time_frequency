%% 辅助校正STFRFT函数的正确性

%% 1、LFM信号的FRFT谱峰值和原始信号的中心频率关系
clear all; clc, close all;
N=256;  t = 1:N;    %采样点数
fs =1;  f0 = 0.5;  fend = -0.1;%采样频率
[s_org,iflaw] = fmlin(N,f0,fend,1);
s = awgn(s_org,50,'measured');
% 计算分数阶的最佳角度
% kgen = diff(iflaw);kgen = [kgen(1);kgen];% IF的导数是斜率k
% popt = -acot(kgen*N)*2/pi; %各个点的最佳FRFT阶数
%-------------------------------------------------
% 中心频率坐标对应FRFT域最大值坐标：实际测试结果
% fc在执行下面操作之前还需要一个校正操作，不然序列太长时估计误差太大！和旋转角度应该相关！
% fc_o = iflaw(N/2)*N; %中心频率
% fc = fc_o * abs(sin(popt(1)*pi/2));
% if fc >= 0 && kgen(N/2)>0; uc = N - fc + 1; 
% elseif fc >= 0 && kgen(N/2)<0; uc = fc - 1;
% elseif fc < 0 && kgen(N/2)<0; uc = N + fc -1;
% elseif fc <0 && kgen(N/2)>0; uc = -fc- 1;
% else uc = - fc; end %中心频率对应FRFT域最大频率
%-------------------------------------------------
% uc = mod(fc_o * sin(popt(1)*pi/2),N);%【映射公式】
% %中心频率到最大频率的映射关系其实是fc_o * sin(popt(1)*pi/2)，归一化到0-N之间即可
% p = popt(1);frt = frft(s,p);
% [~,uc_hat] = max(abs(frt));
% [fc_o,uc,uc_hat]
%-------------------------------------------------
%-----------------------------------------------------------
% 对比FFT和FTFR1的差异并验证FRFT函数的正确性
% p = popt(1);plot(t,abs(fft(s)),'b.-',t,abs(frt),'ro-');legend('fft',['frft p=',num2str(p)])
% 确保FRFT的旋转能量不变正确性验证测试
% r=0.01;     %分数域采样间隔，实际仿真时越小越精确
% for a = 0:r:4
%     T=frft(s,a);         %分数阶傅立叶变换
%     plot(abs(T));title(['a = ',num2str(a)]);
%     if a == 0; pause; else pause(0.02); end
% end
%-----------------------------------------------------------

fLen = N;
[fc,uc,popt] = fftIflaw2frftIflaw(iflaw,fLen);
tfr1 = tfrStft(s,N);% % 计算STFT谱
[tfr2,uc] = tfrStfrft(s,iflaw,N);% 计算最佳旋转角度的分数阶谱
[tfr3,ucf] = stfrftShift(tfr2,fc,uc);% 将求得的STFRFT频谱校正到STFT频谱位置，以方便计算其瞬时频率

subplot(131); imagesc(abs(tfr1)); axis xy; title('STFT');
subplot(132); imagesc(abs(tfr2)); axis xy; title('STFRFT');
subplot(133); imagesc(abs(tfr3)); axis xy; title('STFRFT shift');

% 计算各个时刻点的FRFT域频率
subplot(131); hold on;plot(t,mod(fc,N),'w.--');
subplot(132); hold on;plot(t,mod(uc,N),'w.--');
subplot(133); hold on;plot(t,mod(ucf,N),'w.--');

pause
%% 2、计算SFM信号的FRFT谱
clear all; clc, close all;
N=256;  t = 1:N;    %采样点数
[s_org,iflaw] = fmsin(N,0.1,0.45,200,1,0.2);
s = awgn(s_org,50,'measured');

fLen = 256;%测试发现频率轴点数越多，STFRFT分辨率越高？
[fc,uc,popt] = fftIflaw2frftIflaw(iflaw,fLen);
tfr1 = tfrStft(s,fLen,tftb_window(31));% 计算STFT谱
[tfr2,uc] = tfrStfrft(s,iflaw,fLen,tftb_window(51));% 计算最佳旋转角度的分数阶谱
[tfr3,uc] = stfrftShift(tfr2,fc,uc);% 将求得的STFRFT频谱校正到STFT频谱位置，以方便计算其瞬时频率

subplot(121); imagesc(abs(tfr1)); axis xy;title('STFT');
% subplot(122); imagesc(abs(tfr2)); axis xy;
subplot(122); imagesc(abs(tfr3)); axis xy;title('STFRFT shift');

% 计算各个时刻点的FRFT域频率
subplot(121); hold on;plot(t,mod(fc,fLen),'w.--');
subplot(122); hold on;plot(t,mod(uc,fLen),'w.--');

% figure;plot(t,mod(fc,fLen),'bo-',t,mod(uc,fLen),'ro-',t,popt>0,'x-');

pause
%% 3、叠加分量的STFRFT计算
clear all; clc, close all;
N=256;  t = 1:N;    %采样点数
[s1,iflaw1] = fmsin(N,-0.1,0.25,150,1,0.1);
[s2,iflaw2] = fmlin(N,0.1,0.4,1);
s_org = s1+s2;
s = awgn(s_org,50,'measured');

[fc,uc,popt] = fftIflaw2frftIflaw(iflaw1,N);
tfr1 = tfrStft(s,N,tftb_window(51));% 计算STFT谱
[tfr2,uc] = tfrStfrft(s,iflaw1,N,tftb_window(51));% 计算最佳旋转角度的分数阶谱
[tfr3,uc] = stfrftShift(tfr2,fc,uc);% 将求得的STFRFT频谱校正到STFT频谱位置，以方便计算其瞬时频率

subplot(121); imagesc(abs(tfr1)); axis xy;title('STFT');
subplot(122); imagesc(abs(tfr3)); axis xy;title('STFRFT shift');

% 计算各个时刻点的FRFT域频率
subplot(121); hold on;plot(t,mod(fc,N),'w.--');
subplot(122); hold on;plot(t,mod(uc,N),'w.--');
% 可以选择性的增强某些分量，比如这里增强了SFM信号分量。



%% 4、FRFT的可逆性验证
clear all; clc, close all;
N=64;  t = 1:N;    %采样点数，越小频率跳变越快，但是边缘错误点数量占的比例几乎相同。
[s_org,iflaw] = fmlin(N,0.45,-0.45,1);%调整起始和结束频率可以发现跳变越大恢复错误越多
s = awgn(s_org,10,'measured');%噪声为0dB时也可以较好的恢复中间部分的信号值
kgen = diff(iflaw);kgen = [kgen(1);kgen];% IF的导数是斜率k
popt = -acot(kgen*N)*2/pi; %各个点的最佳FRFT阶数
p = popt(1);%调整阶数围绕popt(1)变化发现差越大恢复的信号差异越大
frt = frft(s,p);%plot(abs(frt))
frt(abs(frt)<max(abs(frt))*0.2) = 0; %模拟去噪操作，这个阈值和噪声相关
sh = ifrft(frt,p);
plot(t,real(s_org),'b.-',t,real(s),'g-',t,real(sh),'rx-'); legend('orignal','noised','transformed');axis tight
%-----------------------------------------------------------
% 正-反变换恢复信号时存在的问题：边缘易错！频率跳变太大也会出错！阶数设置不对会错！！
% 这是离散算法导致的误差，只能近似连续FRFT！！！
% 所以实际应用时可以过采样信号（也可以升[采样FRFT-IFRFT降采样]代替）！
%-----------------------------------------------------------
% 主要是边缘部分的信号失真，信号中点位置通常正确，边缘失真长度和信号长度成比例，
% 占很小的一部分而已。该性质适合STFRFT的时变滤波操作！！！
%-----------------------------------------------------------










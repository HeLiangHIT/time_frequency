%% 原子分解，第一类解决方案


%% 1、gabor语音的STFT
clear,clc
load gabor
time=0:337; subplot(211); 
plot(time,gabor);
dsp=fftshift(abs(fft(gabor)).^2);%FFT
freq=(-169:168)/338*1000; 
subplot(212); plot(freq,dsp);
tfr = tfrstft(gabor);%短时傅立叶变换，
figure,imagesc(time,freq,abs(tfr));axis xy
xlabel('Time [ms]'); ylabel('Frequency [Hz]');
title('Squared modulus of the STFT of the word GABOR');


%% 2、时频分辨率对比
clear all; close all; clc;
x=real(amgauss(128).*fmlin(128));
h=1; %时域高分辨率h=delta
tfrstft(x,1:128,128,h);
h=ones(127,1); %频域高分辨率h=1
tfrstft(x,1:128,128,h);
sig=atoms(128,[45,.25,32,1;85,.25,32,1]);%两个不同到达时刻的相同信号（高斯幅度固定频率）
%总长度为128，第一个中心点为45、频率为0.25fs、持续时间为32个点、幅度为1；第二个中心点为85、频率为.25、持续时间为32个点，幅度为1；
h=hanning(65);
figure,tfrstft(sig,1:128,128,h);%频率分辨率高，但是时域无法分辨是两个信号
h=hanning(17);
figure,tfrstft(sig,1:128,128,h);%时域分辨率很高，但是频域无法分辨具体频点


%% 3、Gobar展示----在不同采样率下的Gobar系数
clear all; close all; clc;
N1=256; Ng=33; Q=1; % 临界采样率
sig=fmlin(N1); 
g=gausswin(Ng); %高斯窗函数
g=g/norm(g);%归一化
[tfr,dgr,h]=tfrgabor(sig,16,Q,g);%Gobar系数求解
% 返回值：Gobar系数平方，Gobar复数系数，g的双正交窗h
subplot(311),plot(h); 
subplot(3,1,[2,3]),imagesc(tfr);axis xy
xlabel('Time'); ylabel('Normalized frequency'); axis('xy');
title('Squared modulus of the Gabor coefficients');
% 可以看出临界采样时h不稳定
Q=4;%4倍过采样
[tfr,dgr,h]=tfrgabor(sig,16,Q,g);%Gobar系数求解
% 返回值：Gobar系数平方，Gobar复数系数，g的双正交窗h
figure,subplot(311),plot(h); 
subplot(3,1,[2,3]),imagesc(tfr);axis xy
xlabel('Time'); ylabel('Normalized frequency'); axis('xy');
title('Squared modulus of the Gabor coefficients');
% 可以看出过采样时h已经很稳定，Q越大越稳定


%% 4、功率谱干扰项和分辨率
clear all; close all; clc;
% 靠近的两个信号----存在交叉干扰
sig=fmlin(128,0,0.4)+fmlin(128,0.1,0.5);
h1=gausswin(23);
figure(1); tfrsp(sig,1:128,128,h1);%计算功率谱，可以指定窗函数
h2=gausswin(63);
figure(2); tfrsp(sig,1:128,128,h2);%默认采用的是汉明窗
% 由于两个分量距离太近导致无论窗长是多少都无法区分开来。
% 远离的两个信号----交叉干扰很小
sig=fmlin(128,0,0.3)+fmlin(128,0.2,0.5);
h1=gausswin(23);
figure(3); tfrsp(sig,1:128,128,h1);%计算功率谱，可以指定窗函数
h2=gausswin(63);
figure(4); tfrsp(sig,1:128,128,h2);%默认采用的是汉明窗
% 窗越短时域分辨率越高，频域分辨率越低。反之亦然。


%% 5、scalogram量图和小波变换
clear all; close all; clc;
sig1=anapulse(128);%Dirac pulse
figure(1),tfrscalo(sig1,1:128,6,0.05,0.45,128,1);%计算量图
% 量图中可以看出高频率部分（对应小的a）时域非常集中，频率减小（a增大）时时域逐渐展宽。
sig2=fmconst(128,.15)+fmconst(128,.35);%两个正弦信号叠加
figure(2),tfrscalo(sig2,1:128,6,0.05,0.45,128,1);
% 可以看到频率分辨率随着频率变化，高频部分分辨率低
% 》》总体而言，交叉干扰部分也都存在，当信号相距足够远时才可能趋于0。





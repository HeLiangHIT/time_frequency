%% 单分量信号的时变滤波重建

%% 1.单分量LFM信号的时变滤波重建
clear all; clc; close all
N=256; t = 1:N;
[s_org,sif] = fmlin(N,0,0.5,120);
s = awgn(real(s_org),5,'measured');% 转化为实数信号，加噪声
% s_hat = stfrftTvf_1Cmpnt(s); % 单分量实数信号时变滤波
s_hat = stftTvf_1Cmpnt(s); % 单分量实数信号时变滤波
figure;plot(t,real(s_org),'b.-',t,real(s),'g',t,real(s_hat),'r.-'); 
axis tight;legend('orignal','noised','TVFed');%xlim([1,128])%查看边缘值


%% 2.单分量AM-LFM-PM信号的时变滤波重建
clear all; clc; close all
N=512;  t = 1:N;
[sfm, sif] = fmlin(N,0,0.5,50);%plot(real(sfm))
sam = (cos(0.05*t)+2)/3;%plot(sam)
s_org = sfm.*sam.';%plot(real(s)) % 幅度调制
s = awgn(real(s_org),5,'measured');% 转化为实数信号，加噪声
% s_hat = stfrftTvf_1Cmpnt(s); % 单分量实数信号时变滤波
s_hat = stftTvf_1Cmpnt(s); % 单分量实数信号时变滤波
figure;plot(t,real(s_org),'b.-',t,real(s),'g',t,real(s_hat),'r.-'); 
axis tight;legend('orignal','noised','TVFed');%xlim([1,128])%查看边缘值
% 噪声太大时主要是IF估计效果太差了，导致该变换的性能也太差了。






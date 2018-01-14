%% STFT下时变滤波的幅度畸变修正测试，采用希尔伯特幅度插值或者拟合的方法修正幅度畸变
% 通常叠加的信号不仅幅度发生畸变，相位也存在畸变，因此不用尝试了。
warning off;

%% STFT下3分量信号分离+幅度校正
clear all; clc; close all
N=512;  t = 1:N;
[s1, sif1] = fmlin(N,0,0.4,120);%假设IF估计精确
[s2, sif2] = fmlin(N,0.4,0,360);
[s3, sif3] = fmlin(N,0.2,0.2,60);
sam3 = (sin(0.05*t.' + pi/16)+2)/3;
s3 = s3.*sam3;
s_org = s1+s2+s3;%信号叠加
s = awgn(s_org,10,'measured');
% s = s_org;
[sh1,tfr,tfrv1] = stftSeparation(s,[sif1,sif2,sif3],20);%固定窗长度的时变滤波
% [sh2,tfr,tfrv2] = stftSeparationAdv(s,[sif1,sif2,sif3],20);%自适应窗长度的时变滤波
shf1 = amplitudeFit(sh1, tfr, tfrv1, 1);%采用幅度拟合的方式恢复--会有相位失真
% shf1 = amplitudeSacle(sh1, tfr, tfrv1);%采用叠加反相的方式恢复
figure;
subplot(311);plot(t,real(s1),'b.-',t,real(s),'g',t,real(sh1(:,1)),'k.-',t,real(shf1(:,1)),'r.-'); 
axis tight;legend('orignal','noised','windowed','adaptive');%xlim([1,128])%查看边缘值
subplot(312);plot(t,real(s2),'b.-',t,real(s),'g',t,real(sh1(:,2)),'k.-',t,real(shf1(:,2)),'r.-'); 
axis tight;legend('orignal','noised','windowed','adaptive');%xlim([1,128])%查看边缘值
subplot(313);plot(t,real(s3),'b.-',t,real(s),'g',t,real(sh1(:,3)),'k.-',t,real(shf1(:,3)),'r.-'); 
axis tight;legend('orignal','noised','windowed','adaptive');%xlim([1,128])%查看边缘值



%%-----------------------------------------------
% 以上信号时变滤波操作可以使用蒙特卡洛模拟得出其MSE曲线。三个分量信号的对比。
% 因此以下设置的三个分量信号分别是LFM、SFM、AM-LFM，蒙特卡洛绘制三个分量信号的MSE即可得到一个曲线图。
%%-----------------------------------------------

% pause
% %% 多种类型的信号混合的信号恢复误差
% clear all; clc; close all
% N=512;  t = 1:N;
% [s1, sif1] = fmlin(N,-0.2,0.1,120);%LFM
% [s2, sif2] = fmsin(N,0.1,0.35,400,1,0.35);%SFM
% [s3, sif3] = fmlin(N,0.2,-0.3,60);%AM-LFM
% sam3 = (sin(0.05*t.' + pi/16)+2)/3;
% s3 = s3.*sam3;
% s_org = s1+s2+s3;%信号叠加
% s = awgn(s_org,0,'measured');



%% 信号幅度插值算法测试
clear all; clc; close all
N=512;  t = 1:N;
[s1, sif1] = fmlin(N,0,0.4,120);%假设IF估计精确
[s2, sif2] = fmlin(N,0.4,0,360);
[s3, sif3] = fmlin(N,0.2,0.2,60);
sam3 = (sin(0.05*t.' + pi/16)+2)/3;
s3 = s3.*sam3;
s_org = s1+s2+s3;%信号叠加
s = awgn(s_org,100,'measured');
% s = s_org;
[sh1,tfr,tfrv1] = stftSeparation(s,[sif1,sif2,sif3],20);%固定窗长度的时变滤波
% [sh2,tfr,tfrv2] = stftSeparationAdv(s,[sif1,sif2,sif3],20);%自适应窗长度的时变滤波
shf1 = amplitudeInterp(sh1, [sif1,sif2,sif3], 30, 1);%采用幅度插值的方式恢复--会有相位失真
figure;
subplot(311);plot(t,real(s1),'b.-',t,real(s),'g',t,real(sh1(:,1)),'k.-',t,real(shf1(:,1)),'r.-'); 
axis tight;legend('orignal','noised','windowed','adaptive');%xlim([1,128])%查看边缘值
subplot(312);plot(t,real(s2),'b.-',t,real(s),'g',t,real(sh1(:,2)),'k.-',t,real(shf1(:,2)),'r.-'); 
axis tight;legend('orignal','noised','windowed','adaptive');%xlim([1,128])%查看边缘值
subplot(313);plot(t,real(s3),'b.-',t,real(s),'g',t,real(sh1(:,3)),'k.-',t,real(shf1(:,3)),'r.-'); 
axis tight;legend('orignal','noised','windowed','adaptive');%xlim([1,128])%查看边缘值







% 采样频率100MHz，幅度1V
% 本脚本文件包含所有【时变滤波理论章节】相关图像生成的语句，
% 某些功能由于太占空间封装到函数里面了，详情查看大注释。


%% 定性的对比基于固定距离和自适应范围的时变滤波实现差异
clear all; clc; close all
Fs = 100;N=512; 
t = (0:(N-1))/Fs; f = linspace(-Fs/2,Fs/2,N);
[s_org,sif] = fmlin(N,0,0.5,120);
s = awgn(s_org,0,'measured');
[sh1,tfr,tfrv1] = stftSeparation(s,sif,30);%固定窗长度的时变滤波
[sh2,tfr,tfrv2] = stftSeparationAdv(s,sif,30);%自适应窗长度的时变滤波

figure('Name','STFT');imagesc(abs(tfr)); set_gca_style([4,4],'img');
figure('Name','STFT-fix-window');imagesc(abs(tfrv1)); set_gca_style([4,4],'img');
figure('Name','STFT-ada-window');imagesc(abs(tfrv2)); set_gca_style([4,4],'img');

figure;plot(t,real(s_org),'b-',t,real(s),'m.-',t,real(sh1),'r^-',t,real(sh2),'kv-');
legend('原信号','带噪声信号','固定窗TVF','自适应窗TVF');
set_gca_style([12,6]); xlim([t(20),t(120)])%查看边缘值
xlabel('时间/\mus'),ylabel('幅度/V');


%% 定量的对比基于固定距离和自适应范围的时变滤波性能差异
TVF_Compare_fixAda_window_STFT();


pause
%% 两无交叉分量信号分离效果对比：定性+定量
% 不交叉，1LFM+1SFM
clear all; clc; close all
Fs = 100;N=256; 
t = (0:(N-1))/Fs; f = linspace(-Fs/2,Fs/2,N);
[s1, sif1] = fmlin(N,0.1,0.2,120);
[s2, sif2] = fmsin(N,0.25,0.45,N+50);
s_org = s1+s2;%信号叠加
s = awgn(s_org,0,'measured');%加5dB噪声【SNR很高时分离的信号几乎完美重合】
figure('Name','sigmix-time');plot(t,real(s_org),'k-',t,real(s),'b--'); legend('叠加信号','带噪声信号');
xlabel('时间/\mus'),ylabel('幅度/V');set_gca_style([12,4]);xlim([t(1),t(128)])%查看边缘值

% [sh1,tfr,tfrv1] = stftSeparation(s,[sif1,sif2],20);%固定窗长度的时变滤波
[sh2,tfr,tfrv2] = stftSeparationAdv(s,[sif1,sif2],20);%自适应窗长度的时变滤波
figure('Name','STFT');imagesc(abs(tfr)); set_gca_style([4,4],'img');
figure('Name','STFT-ada-window-sig1');imagesc(abs(tfrv2(:,:,1))); set_gca_style([4,4],'img');
figure('Name','STFT-ada-window-sig2');imagesc(abs(tfrv2(:,:,2))); set_gca_style([4,4],'img');

figure('Name','sig1-time');plot(t,real(s1),'k-',t,real(sh2(:,1)),'b--'); legend('原始信号','TVF分离信号');
xlabel('时间/\mus'),ylabel('幅度/V');set_gca_style([12,4]);xlim([t(10),t(128)])%查看边缘值
figure('Name','sig2-time');plot(t,real(s2),'k-',t,real(sh2(:,2)),'b--'); legend('原始信号','TVF分离信号');
xlabel('时间/\mus'),ylabel('幅度/V');set_gca_style([12,4]);xlim([t(10),t(128)])%查看边缘值

% 蒙特卡洛仿真对比两分量的RMSE
testN = 20; SNR = -20:2:20;% 仿真参数
rmse = TVF_component_rmse_Monte_Carlo_STFT(s_org,[s1,s2],[sif1,sif2],SNR,testN);
figure('Name','蒙特卡洛仿真分离性能');plot(SNR,rmse(:,1),'b^-',SNR,rmse(:,2),'rv-');legend('分量1','分量2');
xlabel('SNR/dB');ylabel('RMSE');set_gca_style([12,4]);
h2=axes('position',[0.42 0.5 0.25 0.4]);%绘制子图放大
plot(h2,SNR,rmse(:,1),'b^-',SNR,rmse(:,2),'rv-');
axis(h2,[SNR(15),SNR(end),0,1]);

pause
%% 两有交叉分量信号分离效果对比--STFT：定性+定量
% 不交叉，1LFM+1SFM
clear all; clc; close all
Fs = 100;N=256; 
t = (0:(N-1))/Fs; f = linspace(-Fs/2,Fs/2,N);
[s1, sif1] = fmlin(N,0.35,0.1,N/2);
[s2, sif2] = fmsin(N,0.08,0.35,N+50);
s_org = s1+s2;%信号叠加
s = awgn(s_org,0,'measured');%加5dB噪声
figure('Name','sigmix-time');plot(t,real(s_org),'k-',t,real(s),'b--'); legend('叠加信号','带噪声信号');
xlabel('时间/\mus'),ylabel('幅度/V');set_gca_style([12,4]);xlim([t(78),t(180)])%查看边缘值

% [sh1,tfr,tfrv1] = stftSeparation(s,[sif1,sif2],20);%固定窗长度的时变滤波
[sh2,tfr,tfrv2] = stftSeparationAdv(s,[sif1,sif2],20);%自适应窗长度的时变滤波
figure('Name','STFT');imagesc(abs(tfr)); set_gca_style([4,4],'img');
figure('Name','STFT-ada-window-sig1');imagesc(abs(tfrv2(:,:,1))); set_gca_style([4,4],'img');
figure('Name','STFT-ada-window-sig2');imagesc(abs(tfrv2(:,:,2))); set_gca_style([4,4],'img');

% figure('Name','sig1-time');plot(t,real(s1),'k-',t,real(sh2(:,1)),'b--'); legend('原始信号','TVF分离信号');
% xlabel('时间/\mus'),ylabel('幅度/V');set_gca_style([12,4]);xlim([t(78),t(180)])%查看边缘值
% figure('Name','sig2-time');plot(t,real(s2),'k-',t,real(sh2(:,2)),'b--'); legend('原始信号','TVF分离信号');
% xlabel('时间/\mus'),ylabel('幅度/V');set_gca_style([12,4]);xlim([t(78),t(180)])%查看边缘值

% 蒙特卡洛仿真对比两分量的RMSE
testN = 20; SNR = -20:2:20;% 仿真参数
rmse = TVF_component_rmse_Monte_Carlo_STFT(s_org,[s1,s2],[sif1,sif2],SNR,testN);
figure('Name','蒙特卡洛仿真分离性能');h1=axes();
plot(h1,SNR,rmse(:,1),'b^-',SNR,rmse(:,2),'rv-');legend('分量1','分量2');
xlabel('SNR/dB');ylabel('RMSE');set_gca_style([12,4]);
h2=axes('position',[0.42 0.5 0.25 0.4]);%绘制子图放大
plot(h2,SNR,rmse(:,1),'b^-',SNR,rmse(:,2),'rv-');
axis(h2,[SNR(15),SNR(end),0,1]);

% 幅度修正
shf2 = amplitudeFit(sh2, tfr, tfrv2, 1);%采用幅度拟合的方式恢复--会有相位失真
figure('Name','sig1-time');plot(t,real(s1),'k-',t,real(sh2(:,1)),'b--',t,real(shf2(:,1)),'r.:'); legend('原始信号','TVF分离信号','幅度校正信号');
xlabel('时间/\mus'),ylabel('幅度/V');set_gca_style([12,4]);xlim([t(70),t(190)]);ylim([-2,6])%查看边缘值
figure('Name','sig2-time');plot(t,real(s2),'k-',t,real(sh2(:,2)),'b--',t,real(shf2(:,2)),'r.:'); legend('原始信号','TVF分离信号','幅度校正信号');
xlabel('时间/\mus'),ylabel('幅度/V');set_gca_style([12,4]);xlim([t(70),t(190)]);ylim([-2,6])%查看边缘值



pause
%% 两有交叉分量信号分离效果对比--STFRFT：定性+定量
% 不交叉，1LFM+1SFM
clear all; clc; close all
Fs = 100;N=256; %参数需要和上面的一样以便对比
t = (0:(N-1))/Fs; f = linspace(-Fs/2,Fs/2,N);
[s1, sif1] = fmlin(N,0.35,0.1,N/2);
[s2, sif2] = fmsin(N,0.08,0.35,N+50);
s_org = s1+s2;%信号叠加
s = awgn(s_org,0,'measured');%加5dB噪声

% [sh1,tfr,tfrv1] = stfrftSeparation(s,[sif1,sif2],8);%自适应窗长度的时变滤波
[sh2,tfr,tfrv2] = stfrftSeparationAdv(s,[sif1,sif2],8);%自适应窗长度的时变滤波--FRFT能量更集中，因此需要的宽度更小
figure('Name','STFRFT-sig1');imagesc(abs(tfr(:,:,1))); set_gca_style([4,4],'img');
figure('Name','STFRFT-sig2');imagesc(abs(tfr(:,:,2))); set_gca_style([4,4],'img');
figure('Name','STFRFT-ada-window-sig1');imagesc(abs(tfrv2(:,:,1))); set_gca_style([4,4],'img');
figure('Name','STFRFT-ada-window-sig2');imagesc(abs(tfrv2(:,:,2))); set_gca_style([4,4],'img');

% figure('Name','sig1-time');plot(t,real(s1),'k-',t,real(sh2(:,1)),'b--'); legend('原始信号','TVF分离信号');
% xlabel('时间/\mus'),ylabel('幅度/V');set_gca_style([12,4]);xlim([t(78),t(180)]);ylim([-2,2])%查看边缘值
% figure('Name','sig2-time');plot(t,real(s2),'k-',t,real(sh2(:,2)),'b--'); legend('原始信号','TVF分离信号');
% xlabel('时间/\mus'),ylabel('幅度/V');set_gca_style([12,4]);xlim([t(78),t(180)]);ylim([-2,2])%查看边缘值

% 蒙特卡洛仿真对比两分量的RMSE
testN = 20; SNR = -20:2:20;% 仿真参数
rmse = TVF_component_rmse_Monte_Carlo_STFRFT(s_org,[s1,s2],[sif1,sif2],SNR,testN);
figure('Name','蒙特卡洛仿真分离性能');h1=axes();
plot(h1,SNR,rmse(:,1),'b^-',SNR,rmse(:,2),'rv-');legend('分量1','分量2');
xlabel('SNR/dB');ylabel('RMSE');set_gca_style([12,4]);
h2=axes('position',[0.42 0.5 0.25 0.4]);%绘制子图放大
plot(h2,SNR,rmse(:,1),'b^-',SNR,rmse(:,2),'rv-');
axis(h2,[SNR(15),SNR(end),0,1]);

Results_File = ['TVF_component_rmse_Monte_Carlo_STFRFT_2sig',datestr(clock,'_yyyy_mm_dd_hh_MM')];
save(Results_File,'SNR','rmse');

[~,tfr,tfrv2] = stftSeparationAdv(s,[sif1,sif2],20);%获取交叉分量位置需要用到
shf2 = amplitudeFit(sh2, tfr, tfrv2, 1);%采用幅度拟合的方式恢复--会有相位失真
figure('Name','sig1-time');plot(t,real(s1),'k-',t,real(sh2(:,1)),'b--',t,real(shf2(:,1)),'r.:'); legend('原始信号','TVF分离信号','幅度校正信号');
xlabel('时间/\mus'),ylabel('幅度/V');set_gca_style([12,4]);xlim([t(70),t(190)]);ylim([-2,6])%查看边缘值
figure('Name','sig2-time');plot(t,real(s2),'k-',t,real(sh2(:,2)),'b--',t,real(shf2(:,2)),'r.:'); legend('原始信号','TVF分离信号','幅度校正信号');
xlabel('时间/\mus'),ylabel('幅度/V');set_gca_style([12,4]);xlim([t(70),t(190)]);ylim([-2,6])%查看边缘值


pause
%% 不同信号TVF下算法的RMSE性能对比：多类信号
% 2LFM+1SFM
clear all; clc; close all;
testN = 20; SNR = -20:5:20;% 仿真参数
N=128;  t = 1:N;
[s1, sif1] = fmlin(N,0.03,0.09);
[s2, sif2] = fmlin(N,0.31,0.5);
[s3, sif3] = fmsin(N,0.15,0.28,N);
s_org = s1+s2+s3;%tfr = tfrstft(s_org);imagesc(abs(tfr));axis xy
% figure('Name','sigmix-time');plot(t,real(s_org),'k-'); xlabel('时间/\mus'),ylabel('幅度/V');set_gca_style([12,4]);
% figure('Name','tfrwv');tfr = tfrstft(s_org);imagesc(abs(tfr));set_gca_style([4,4],'img');%imagesc(abs(tfrADTFD(s_org,2,14,82)));

rmse = TVF_component_rmse_Monte_Carlo(s_org,[s1,s2,s3],[sif1,sif2,sif3],SNR,testN,10,6,50);
rmseSum = mean(rmse,2);
figure('Name','蒙特卡洛仿真分离性能2LFM1SFM');label={'ko-','ksquare-','kdiamond-','kx-','rv-','r^-','r<-','r>-','bpentagram-','bhexagram-','m+-','m*-','mx-'};%标注所用，支持最多13种线型
% for k=1:8; plot(SNR,20*log(rmseSum(:,1,k)),label{k});hold on; end%考虑全部分量性能并不好
for k=1:8; plot(SNR,20*log(rmse(:,3,k)),label{k});hold on;   end  %只考虑第三个非线性分量其性能才能更好
legend('STFT-F','STFT-FM','STFT-A','STFT-AM','STFRFT-F','STFRFT-FM','STFRFT-A','STFRFT-AM');
xlabel('SNR/dB');ylabel('RMSE/dB');set_gca_style([16,8]);

Results_File = ['TVF_component_rmse_Monte_Carlo_2LFM1SFM',datestr(clock,'_yyyy_mm_dd_hh_MM')];
save(Results_File,'SNR','rmse');pause(0.1)


% 3LFM相交
clear all; clc; close all;
testN = 20; SNR = -20:5:20;% 仿真参数
N=128;  t = 1:N;
[s1, sif1] = fmlin(N,0,0.4,29);
[s2, sif2] = fmlin(N,0.4,0,90);
[s3, sif3] = fmlin(N,0.2,0.2,14);
s_org = s1+s2+s3;%tfr = tfrstft(s_org);imagesc(abs(tfr))
% figure('Name','sigmix-time');plot(t,real(s_org),'k-'); xlabel('时间/\mus'),ylabel('幅度/V');set_gca_style([12,4]);
% figure('Name','tfrwv');tfr = tfrstft(s_org);imagesc(abs(tfr));set_gca_style([4,4],'img');%imagesc(abs(tfrADTFD(s_org,2,14,82)));


rmse = TVF_component_rmse_Monte_Carlo(s_org,[s1,s2,s3],[sif1,sif2,sif3],SNR,testN,10,6,3);
rmseSum = mean(rmse,2);
figure('Name','蒙特卡洛仿真分离性能3LFM');label={'ko-','ksquare-','kdiamond-','kx-','rv-','r^-','r<-','r>-','bpentagram-','bhexagram-','b+-','b*-','mx-'};%标注所用，支持最多13种线型
for k=1:8; plot(SNR,20*log(rmseSum(:,1,k)),label{k});hold on;   end
for k=4:8; plot(SNR,20*log((rmse(:,1,k)+rmse(:,2,k))/2),label{k+4});hold on;   end% 只考虑倾斜分量
legend('STFT-F','STFT-FM','STFT-A','STFT-AM','STFRFT-F','STFRFT-FM','STFRFT-A','STFRFT-AM');
xlabel('SNR/dB');ylabel('RMSE/dB');set_gca_style([16,8]);

Results_File = ['TVF_component_rmse_Monte_Carlo_3LFM',datestr(clock,'_yyyy_mm_dd_hh_MM')];
save(Results_File,'SNR','rmse');pause(0.1)


% 3LFM+1SFM
clear all; clc; %close all;
testN = 20; SNR = -20:5:20;% 仿真参数
N=128;  t = 1:N;
[s1, sif1] = fmlin(N,0.05,0.11,30);
[s2, sif2] = fmlin(N,0.1,0.2,1);
[s3, sif3] = fmsin(N,0.22,0.42,128);
[s4, sif4] = fmlin(N,0.4,0.16,1);
s_org = s1+s2+s3+s4;%tfr = tfrstft(s_org);imagesc(abs(tfr))
% figure('Name','sigmix-time');plot(t,real(s_org),'k-'); xlabel('时间/\mus'),ylabel('幅度/V');set_gca_style([12,4]);
% figure('Name','tfrwv');tfr = tfrstft(s_org);imagesc(abs(tfr));set_gca_style([4,4],'img');%imagesc(abs(tfrADTFD(s_org,2,14,82)));

rmse = TVF_component_rmse_Monte_Carlo(s_org,[s1,s2,s3,s4],[sif1,sif2,sif3,sif4],SNR,testN,10,6,50);
rmseSum = mean(rmse,2);
figure('Name','蒙特卡洛仿真分离性能3LFM+1SFM');label={'ko-','ksquare-','kdiamond-','kx-','rv-','r^-','r<-','r>-','bpentagram-','bhexagram-','m+-','m*-','mx-'};%标注所用，支持最多13种线型
for k=1:8; plot(SNR,20*log(rmseSum(:,1,k)),label{k});hold on;   end
% for k=1:8; plot(SNR,20*log(rmse(:,1,k)),label{k});hold on;   end
legend('STFT-F','STFT-FM','STFT-A','STFT-AM','STFRFT-F','STFRFT-FM','STFRFT-A','STFRFT-AM');
xlabel('SNR/dB');ylabel('RMSE/dB');set_gca_style([16,8]);

Results_File = ['TVF_component_rmse_Monte_Carlo_3LFM1SFM',datestr(clock,'_yyyy_mm_dd_hh_MM')];
save(Results_File,'SNR','rmse');pause(0.1)







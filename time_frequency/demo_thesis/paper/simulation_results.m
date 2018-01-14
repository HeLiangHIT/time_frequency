%% 主要考虑的三种仿真信号的时变滤波性能比较
%%%%%%%% 2LFM+1SFM
clear all; clc; close all;
testN = 50; SNR = -20:5:20;% 仿真参数
N=128;  t = 1:N;
[s1, sif1] = fmlin(N,0.03,0.09);
[s2, sif2] = fmlin(N,0.31,0.5);
[s3, sif3] = fmsin(N,0.15,0.28,N);
s_org = s1+s2+s3;

[~,tfr,tfrv2] = stftSeparationAdv(s_org,[sif1,sif2,sif3],8);%自适应窗长度的时变滤波
figure('Name','STFT');imagesc(abs(tfr)); set_gca_style([4,4],'img');
figure('Name','STFT-window');imagesc(abs(tfrv2(:,:,3))); set_gca_style([4,4],'img');
[~,tfrfr,tfrfrv] = stfrftSeparationAdv(s_org,[sif1,sif2,sif3],5);
figure('Name','STFRFT');imagesc(abs(tfrfr(:,:,3))); set_gca_style([4,4],'img');
figure('Name','STFRFT-window');imagesc(abs(tfrfrv(:,:,3))); set_gca_style([4,4],'img');
[~,tfrcw,tfrcwv] = synsqCwtSeparationAdv(s_org,[sif1,sif2,sif3],5);
figure('Name','SQCWT');imagesc(abs(tfrcw)); set_gca_style([4,4],'img');
figure('Name','SQCWT-window');imagesc(abs(tfrcwv(:,:,3))); set_gca_style([4,4],'img');

rmse = TVF_component_rmse_Monte_Carlo(s_org,[s1,s2,s3],[sif1,sif2,sif3],SNR,testN,12,6);
rmseSum = mean(rmse,2);
figure('Name','蒙特卡洛仿真分离性能2LFM+1SFM');label={'ko-','bsquare-','rdiamond-','kx-','rv-','r^-','r<-','r>-','bpentagram-','bhexagram-','m+-','m*-','mx-'};%标注所用，支持最多13种线型
for k=1:3; plot(SNR,10*log(rmseSum(:,1,k)),label{k});hold on;   end
legend('STFT','STFRFT','SWT');
xlabel('SNR/dB');ylabel('RMSE/dB');set_gca_style([10,6]);

Results_File = ['TVF_component_rmse_Monte_Carlo_2LFM1SFM',datestr(clock,'_yyyy_mm_dd_hh_MM')];
save(Results_File);





%%%%%%%% 3LFM+1SFM+cross
clear all; clc;% close all;
testN = 50; SNR = -20:5:20;% 仿真参数
N=128;  t = 1:N;
[s1, sif1] = fmlin(N,0.05,0.11,30);
[s2, sif2] = fmlin(N,0.1,0.2,1);
[s3, sif3] = fmsin(N,0.22,0.42,128);
[s4, sif4] = fmlin(N,0.4,0.16,1);
s_org = s1+s2+s3+s4;

[~,tfr,tfrv2] = stftSeparationAdv(s_org,[sif1,sif2,sif3,sif4],8);%自适应窗长度的时变滤波
figure('Name','STFT');imagesc(abs(tfr)); set_gca_style([4,4],'img');
figure('Name','STFT-window');imagesc(abs(tfrv2(:,:,3))); set_gca_style([4,4],'img');
[sh2,tfrfr,tfrfrv] = stfrftSeparationAdv(s_org,[sif1,sif2,sif3,sif4],5);
figure('Name','STFRFT');imagesc(abs(tfrfr(:,:,3))); set_gca_style([4,4],'img');
figure('Name','STFRFT-window');imagesc(abs(tfrfrv(:,:,3))); set_gca_style([4,4],'img');
[~,tfrcw,tfrcwv] = synsqCwtSeparationAdv(s_org,[sif1,sif2,sif3,sif4],5);
figure('Name','SQCWT');imagesc(abs(tfrcw)); set_gca_style([4,4],'img');
figure('Name','SQCWT-window');imagesc(abs(tfrcwv(:,:,3))); set_gca_style([4,4],'img');

rmse = TVF_component_rmse_Monte_Carlo(s_org,[s1,s2,s3,s4],[sif1,sif2,sif3,sif4],SNR,testN,10,6);
rmseSum = mean(rmse,2);
figure('Name','蒙特卡洛仿真分离性能3LFM+1SFM');label={'ko-','bsquare-','rdiamond-','kx-','rv-','r^-','r<-','r>-','bpentagram-','bhexagram-','m+-','m*-','mx-'};%标注所用，支持最多13种线型
for k=1:3; plot(SNR,10*log(rmseSum(:,1,k)),label{k});hold on;   end
legend('STFT','STFRFT','SWT');
xlabel('SNR/dB');ylabel('RMSE/dB');set_gca_style([10,6]);

Results_File = ['TVF_component_rmse_Monte_Carlo_3LFM1SFM',datestr(clock,'_yyyy_mm_dd_hh_MM')];
save(Results_File);




%%%%%%%% 2SFM + cross
clear all; clc;% close all;
testN = 50; SNR = -20:5:20;% 仿真参数
N=128;  t = 1:N;
[s1, sif1] = fmsin(N,0.16,0.35,256,1,0.32,-1);
[s2, sif2] = fmsin(N,0.08,0.43,90,1,0.08);
s_org = s1+s2;

[~,tfr,tfrv2] = stftSeparationAdv(s_org,[sif1,sif2],13);%自适应窗长度的时变滤波
figure('Name','STFT');imagesc(abs(tfr)); set_gca_style([4,4],'img');
figure('Name','STFRFT-window');imagesc(abs(tfrv2(:,:,2))); set_gca_style([4,4],'img');
[sh2,tfrfr,tfrfrv] = stfrftSeparationAdv(s_org,[sif1,sif2],8);
figure('Name','STFRFT');imagesc(abs(tfrfr(:,:,2))); set_gca_style([4,4],'img');
figure('Name','STFRFT-window');imagesc(abs(tfrfrv(:,:,2))); set_gca_style([4,4],'img');
[~,tfrcw,tfrcwv] = synsqCwtSeparationAdv(s_org,[sif1,sif2],5);
figure('Name','SQCWT');imagesc(abs(tfrcw)); set_gca_style([4,4],'img');
figure('Name','SQCWT-window');imagesc(abs(tfrcwv(:,:,2))); set_gca_style([4,4],'img');

rmse = TVF_component_rmse_Monte_Carlo(s_org,[s1,s2],[sif1,sif2],SNR,testN,8,3);
rmseSum = mean(rmse,2);
figure('Name','蒙特卡洛仿真分离性能2SFM');label={'ko-','bsquare-','rdiamond-','kx-','rv-','r^-','r<-','r>-','bpentagram-','bhexagram-','m+-','m*-','mx-'};%标注所用，支持最多13种线型
for k=1:3; plot(SNR,10*log(rmseSum(:,1,k)),label{k});hold on;   end
legend('STFT','STFRFT','SWT');
xlabel('SNR/dB');ylabel('RMSE/dB');set_gca_style([10,6]);

Results_File = ['TVF_component_rmse_Monte_Carlo_2SFM',datestr(clock,'_yyyy_mm_dd_hh_MM')];
save(Results_File);




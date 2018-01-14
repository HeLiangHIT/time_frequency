%% TFR修正算法

% 信号产生
clear all; clc; close all;
Fs = 100;N=256; %单位对应MHz, us
t = (0:(N-1))/Fs; f = linspace(0,Fs/2,N);
[s1, sif1] = fmlin(N,0.05,0.2);
[s2, sif2] = fmlin(N,0.35,0.09);
[s3, sif3] = fmsin(N,0.15,0.28,300);
s_org = s1+s2+s3;
s = awgn(s_org,100,'measured');% 5, 0, -5
tfr = tfrADTFD(s,2,15,82);%figure;imagesc(tfr);axis xy;

[beta0, beta1, beta2]= gradientVector(tfr,2);%公式6计算beta0、1、2
[beta1fix, beta2fix] = vectorModify(beta1,beta2);% 梯度向量修正

[x,y] = meshgrid(1:size(tfr,2),1:size(tfr,1));%绘图专用坐标修正
figure; quiver(x(:),y(:),beta2(:),beta1(:));axis equal;axis tight;axis([115,150,100,130])%绘制Fig2左，这里的beta1和beta2与书上貌似有点反
figure; quiver(x(:),y(:),beta2fix(:),beta1fix(:));axis equal;axis tight;axis([115,150,100,130])%绘制Fig2左，这里的beta1和beta2与书上貌似有点反

%% 计算均率图像Mean ratio images，并根据能量占比二值化
rImg = meanGradientRatioImg(beta0, beta1, beta2, beta1fix, beta2fix, 7);figure; imagesc(rImg); axis xy;
% rImg = meanGradientRatioImgEasy(beta0, beta1, beta2, beta1fix, beta2fix,3);figure; imagesc(rImg); axis xy;
% rImgFilter = filter2(fspecial('gaussian',8),rImg);%surf(rImgFilter);%自适应处理的图像比较尖锐，可以适当的平滑以便IF提取
segs = 1000;%rImg细分数量
portion = 0.97;%rImg置0数量
rBin = gradientImg2Bin(rImgFilter, segs, portion);%imshow(rBin)
rImgFix = rImg.*rBin;imagesc(rImgFix);


% 频率估计算法
delta_freq_samples= 10;%IF追踪的梯度，设置最大为10个图像距离
min_track_length= 1;%最短跟踪IF片段长度
max_peaks= 3;%每个时刻最大的重复IF数量
hif1=tracks_MCQmethod(rImgFix',Fs,delta_freq_samples,min_track_length,max_peaks);%1986
lower_prctile_limit= 90; % 忽略低于该能量的百分比
hif2=tracks_LRmethod(rImgFix',1,delta_freq_samples,min_track_length,lower_prctile_limit);%2007
% tfps = tfdpeaks(rImgFix', 2);%第二个参数是peaks的百分比，越小检测出的峰值越多
% [hif2, cps] = edgelink3(tfps,1); %第二个参数是最短边缘长度

figure(1); clf; hold all;
for n=1:length(hif1);    hmcq=plot(hif1{n}(:,1),hif1{n}(:,2),'ko-'); end
for n=1:length(hif2);    hlr=plot(hif2{n}(:,1),hif2{n}(:,2),'r+-'); end
xlabel('time (seconds)'); ylabel('frequency (Hz)');axis tight
legend([hlr hmcq],{'LR method','MCQ method'});


% 测试自己修改的算法实现效果
delta_time_samples = 15;% 允许的时间跳变距离
hif3=tracks_LRmethod_my(rImg2Fix',delta_time_samples,delta_freq_samples,min_track_length,lower_prctile_limit);
figure(1); clf; hold all;
for n=1:length(hif3);    hlr=plot(hif3{n}(:,1),hif3{n}(:,2),'r+-'); end
% 自己发明的IF估计算法
rBin = gradientImg2Bin(img, 1000, 0.95);
rBinClean = bwareaopen(rBin,cleanArea,8);%imshow(rBinClean)
rBinfix = bwmorph(rBinClean,'thin',1000);%细化的次数和之前选择的窗长度有关
% figure;subplot(211);imshow(rBin);axis xy;
% subplot(212);imshow(rBinfix);axis xy;
% [L,num] = bwlabel(rBinfix, 8); S = regionprops(L, 'Area');lineSkel = bwmorph(rBin,'skel',Inf);
[hif4, bimg]= bwboundaries(rBinfix',8);


%% 片段连接和拟合算法
% linesSim = linesSimplify(hif1);%曲线去重--这些算法估计的瞬时频率片段不会出现重叠情况
linesInfo = curveModify(hif1,length(s),-3);%修复曲线分岔问题和垂直方向上存在多个点的问题
figure;label={'ko-','bsquare-','rdiamond-','kv-','b^-','r<-','k<-','bpentagram-','rhexagram-','k+-','b*-','r.-','kx-'};
for k = 1:length(linesInfo)
    plot(linesInfo{k}.line(:,1),linesInfo{k}.line(:,2),label{1+mod(k,length(label))});hold on; grid on
    linesInfo{k}.type
end
linesCon = linesConnect(linesInfo,40);%曲线拼接%k=1;plot(linesCon{k}(:,1),linesCon{k}(:,2),'rx-');hold on; grid on
linesFinal = curveModify(linesCon,length(s),256);
figure;label={'ko-','bsquare-','rdiamond-','kv-','b^-','r<-','k<-','bpentagram-','rhexagram-','k+-','b*-','r.-','kx-'};
for k = 1:length(linesFinal)
    plot(linesFinal{k}.line(:,1),linesFinal{k}.line(:,2),label{k});hold on; grid on
    linesFinal{k}.type
end

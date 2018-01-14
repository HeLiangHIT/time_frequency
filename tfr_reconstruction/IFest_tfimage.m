%% 验证文献IF estimation of FM signals based on time-frequency image 中的信号
clear;clc;close all;

%% 1、信号交叉处并不一定都是峰值
% 信号产生
T0 = 14;
N=1024;t = 0:(N-1);
[s1,if1] = fmlin(N, 0.4, 0, T0);
[s2,if2] = fmsin(N,0.1,0.4,N*2,T0,0.1,-1);
s = real(s1+s2);

% 信号产生
% T0 = 2;T3 = 5;
% N=1024;t = 0:(N-1);
% [s1,if1] = fmlin(N, 0.35, 0.4, T0);
% [s2,if2] = fmsin(N,0.1,0.3,N*2/1.5,N/2,0.1,1);
% [s3,if3] = fmlin(N, 0.1, 0.35, T0);
% s = s1+s2+s3;

% TFR计算
tfr = quadtfd( s, 127, 1, 'emb',0.03,0.3);%计算BD谱
figure; 
% p = tfsapl( s, tfr);
imagesc(tfr); colormap('hot');axis xy;%
%作者采用的是EMBD谱而不是通常意义的BD谱。


%% 2、梯度图像处理后的二值化结果也不是交叉处断裂的
% img = tfr(:,1:2:end);%图像模拟
% portion = 0.96;%图像二值化
% [lines,rBin,rImg] = IfLineSegmentDetection(img,portion,'gradient');%获取图像中的曲线信息
% figure;imshow(rBin);%figure; p = tfsapl( s, rImg);



%% 3、作者的出发点是针对峰值的情况处理，检测出一些峰值片段来连接。何不直接检测峰值呢？？  




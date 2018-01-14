%% 信号增强算法相关理论的图像产生

%% 信号产生
clear all; clc; close all;
Fs = 100;N=256; %单位对应MHz, us
t = (0:(N-1))/Fs; f = linspace(0,Fs/2,N);
[s1, sif1] = fmlin(N,0.05,0.2);
[s2, sif2] = fmlin(N,0.35,0.09);
[s3, sif3] = fmsin(N,0.15,0.28,300);
s_org = s1+s2+s3;
s = awgn(s_org,100,'measured');% 5, 0, -5
tfr = tfrADTFD(s,2,15,82);
% tfr = tfr + 0.3*rand(N,N);% 加点噪声示意
figure;imagesc(tfr);%set_gca_style([12,6],'img');colormap('Cool');


%% 计算梯度旋转增强图像
[beta0, beta1, beta2]= gradientVector(tfr,2);%公式6计算beta0、1、2
[beta1fix, beta2fix] = vectorModify(beta1,beta2);% 梯度向量修正

[x,y] = meshgrid(1:size(tfr,2),1:size(tfr,1));%绘图专用坐标修正
figure('Name','原始梯度矩阵'); quiver(x(:),y(:),beta2(:),beta1(:));
% set_gca_style([6,1.5]);
axis equal;axis off;set(gca, 'position', [0 0 1 1 ]);
% axis([50,90,140,150]);%axis([150,190,110,120]);%axis([110,150,108,118]);
figure('Name','旋转梯度矩阵'); quiver(x(:),y(:),beta2fix(:),beta1fix(:));
% set_gca_style([6,1.5]);
axis equal;axis off;set(gca, 'position', [0 0 1 1 ]);
% axis([50,90,140,150]);%axis([150,190,110,120]);%axis([110,150,108,118]);

rImg1 = meanGradientRatioImgEasy(beta0, beta1, beta2, beta1fix, beta2fix,2);
figure('Name','固定窗增强'); imagesc(rImg1); %set_gca_style([6,6],'img');
rImg2 = meanGradientRatioImg(beta0, beta1, beta2, beta1fix, beta2fix, 7);
figure('Name','自适应窗增强'); imagesc(rImg2); %set_gca_style([6,6],'img');
rBin = gradientImg2Bin(rImg2, 1000, 0.98);%imshow(rBin)
rImg2Fix = rImg2.*rBin;imagesc(rImg2Fix);


%% 增强后的时频分布下进行IF估计
img = rImg2Fix';%选择图像
[hif1,~] = IFest_compare_algorithm(img,5,10,3,90);
hif2 =tracks_LRmethod_my(img,4,10,1,90);
% 结果绘制
figure('Name','IF algorithms compare');F_scale = Fs/N/2;
for n=1:length(hif1) ;   hmcq=plot(hif1{n}(1:5:end,1)/Fs,hif1{n}(1:5:end,2)*F_scale,'ro-','MarkerSize',6); hold on; end   %绘制IF曲线
for n=1:length(hif2) ;   hlr=plot(hif2{n}(1:5:end,1)/Fs,hif2{n}(1:5:end,2)*F_scale,'bsquare-','MarkerSize',2.5); hold on; end   %绘制IF曲线
legend([hlr hmcq],{'LPDCL','BDIF'}); %set_gca_style([6,6]);
grid off; ylim([0,60]);%方便放置图例
xlabel('时间/\mus');ylabel('频率/Mhz');
% axis([1.1,2.1,12,25]);


pause
close all;
%% IF片段的连接算法
% IF片段拟合
label={'ko-','bsquare-','rdiamond-','kv-','b^-','r<-','k<-','bpentagram-','rhexagram-','k+-','b*-','r.-','kx-'};%绘图参数
linesInfo = curveModify(hif1,length(s),-2);%修复曲线分岔问题和垂直方向上存在多个点的问题
figure('Name','IFs FIT');
for n=1:length(hif1) ;   hmcq=plot(hif1{n}(1:5:end,1)/Fs,hif1{n}(1:5:end,2)*F_scale,'ro-','MarkerSize',6); hold on;  end   %绘制IF曲线
for k = 1:length(linesInfo);    hfit = plot(linesInfo{k}.line(1:5:end,1)/Fs,linesInfo{k}.line(1:5:end,2)*F_scale,'b.-','MarkerSize',2.5);hold on;  end
legend([hmcq,hfit],{'IF片段','拟合IF片段'}); %set_gca_style([6,6]);
grid off; ylim([0,60]);%方便放置图例
xlabel('时间/\mus');ylabel('频率/Mhz');

% IF片段连接
linesCon = linesConnect(linesInfo,40);%曲线拼接
figure('Name','IFs Connect');
for k=1:length(linesCon);plot(linesCon{k}(1:5:end,1)/Fs,linesCon{k}(1:5:end,2)*F_scale,label{k});hold on; end
% set_gca_style([6,6]);
grid off; ylim([0,50]);xlabel('时间/\mus');ylabel('频率/Mhz');

% 分量拟合
linesFinal = curveModify(linesCon,length(s),256);
figure('Name','IF FIT-pro');
for k = 1:length(linesFinal);    plot(linesFinal{k}.line(1:5:end,1)/Fs,linesFinal{k}.line(1:5:end,2)*F_scale, label{k});hold on; end
% set_gca_style([6,6]);
grid off; ylim([0,50]);xlabel('时间/\mus');ylabel('频率/Mhz');


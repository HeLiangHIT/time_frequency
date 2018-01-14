function  [s,s_org,sif,sif_hat] = IFest_compare_signalSS()
%% 对比不同信号下：TFR-增强-IF估计-片段连接 整个流程IF估计结果

%% 信号产生
clear all; close all; clc
Fs = 100;N=256; %单位对应MHz, us
t = (0:(N-1))/Fs; f = linspace(0,Fs/2,N);
[s1,sif1]=fmsin(N,0.1,0.4,128,1,0.1,1);%(N,FNORMIN,FNORMAX,PERIOD,T0,FNORM0,PM1)
[s2,sif2]=fmsin(N,0.1,0.4,128,1,0.4,1);%(N,FNORMIN,FNORMAX,PERIOD,T0,FNORM0,PM1)
s = s1+s2; sif = [sif1,sif2]; s_org = [s1, s2];% tfrspwv(s);
% s = awgn(s,10,'measured');
tfr = tfrADTFD(s,3,20,82);%
figure('Name','ADTFR');imagesc(tfr);set_gca_style([5,5],'img');

%% 算法实现
win1 = 2; win2 = 5;

[beta0, beta1, beta2]= gradientVector(tfr,win1);%公式6计算beta0、1、2
[beta1fix, beta2fix] = vectorModify(beta1,beta2);% 梯度向量修正

% [x,y] = meshgrid(1:size(tfr,2),1:size(tfr,1));%绘图专用坐标修正
% figure('Name','原始梯度矩阵'); quiver(x(:),y(:),beta2(:),beta1(:));
% set_gca_style([6,1.5]);axis equal;axis off;set(gca, 'position', [0 0 1 1 ]);
% axis([50,90,140,150]);%axis([150,190,110,120]);%axis([110,150,108,118]);
% figure('Name','旋转梯度矩阵'); quiver(x(:),y(:),beta2fix(:),beta1fix(:));
% set_gca_style([6,1.5]);axis equal;axis off;set(gca, 'position', [0 0 1 1 ]);
% axis([50,90,140,150]);%axis([150,190,110,120]);%axis([110,150,108,118]);

% rImg1 = meanGradientRatioImgEasy(beta0, beta1, beta2, beta1fix, beta2fix,win1);
% figure('Name','固定窗增强'); imagesc(rImg1); set_gca_style([6,6],'img');
rImg2 = meanGradientRatioImg(beta0, beta1, beta2, beta1fix, beta2fix, win2);
figure('Name','自适应窗增强'); imagesc(rImg2); set_gca_style([5,5],'img');
% rBin = gradientImg2Bin(rImg2, 1000, 0.98);%imshow(rBin)
% rImg2Fix = rImg2.*rBin;imagesc(rImg2Fix);set_gca_style([6,6],'img');


img = rImg2';%选择图像
[hif1,~] = IFest_compare_algorithm(img,5,10,3,90);%只选择BDIF算法的输出作为估计
% hif3 =tracks_LRmethod_my(img,4,10,1,90);
% 结果绘制
figure('Name','IF algorithms compare');F_scale = Fs/N/2;
for n=1:length(hif1) ;   hmcq=plot(hif1{n}(:,1)/Fs,hif1{n}(:,2)*F_scale,'r-'); hold on;  end   %绘制IF曲线
% for n=1:length(hif3) ;   hlr=plot(hif3{n}(:,1)/Fs,hif3{n}(:,2)*F_scale,'b:'); hold on; end   %绘制IF曲线
% legend([hlr hmcq],{'LPDCL','BDIF'}); 
set_gca_style([6,6]);grid off; ylim([0,50]);%方便放置图例
xlabel('时间/\mus');ylabel('频率/Mhz');
% axis([1.1,2.1,12,25]);

%% 图像连接算法
% IF片段拟合
label={'ro-','b.-','r^-','kv-','b^-','r<-','k<-','bpentagram-','rhexagram-','k+-','b*-','r.-','kx-'};%绘图参数
linesInfo = curveModify(hif1,length(s),-2);%修复曲线分岔问题和垂直方向上存在多个点的问题
% figure('Name','IFs FIT');
% for n=1:length(hif1) ;   hmcq=plot(hif1{n}(:,1)/Fs,hif1{n}(:,2)*F_scale,'ro-'); hold on;  end   %绘制IF曲线
% for k = 1:length(linesInfo);    hfit = plot(linesInfo{k}.line(:,1)/Fs,linesInfo{k}.line(:,2)*F_scale,'b.-');hold on;  end
% legend([hmcq,hfit],{'IF片段','拟合IF片段'}); set_gca_style([6,6]);grid off; ylim([0,50]);%方便放置图例
% xlabel('时间/\mus');ylabel('频率/Mhz');

% IF片段连接
linesCon = linesConnect(linesInfo,40);%曲线拼接
% figure('Name','IFs Connect');
% for k=1:length(linesCon);plot(linesCon{k}(:,1)/Fs,linesCon{k}(:,2)*F_scale,label{k});hold on; end
% set_gca_style([6,6]);grid off; ylim([0,50]);xlabel('时间/\mus');ylabel('频率/Mhz');

% 分量拟合
enLen = 20;
linesFinal = curveModify(linesCon,length(s),enLen);%--不要延伸太长以避免错误的IF也充满全屏
figure('Name','IF FIT-pro');
for k = 1:length(linesFinal);    
    if length(linesFinal{k}.line)<(enLen*2 + 50); continue;end %% 去掉太短的IF分量信号
    plot(linesFinal{k}.line(1:5:end,1)/Fs,linesFinal{k}.line(1:5:end,2)*F_scale, label{k});hold on; 
end
set_gca_style([6,6]);grid off; ylim([0,50]);xlabel('时间/\mus');ylabel('频率/Mhz');
% plot(t,sif1*Fs,'b^',t,sif2*Fs,'rv');

sif_hat = linesFinal;

end



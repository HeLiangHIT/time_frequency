% 采样频率100MHz，幅度1V
% 本脚本文件包含所有【时频分析理论章节】相关图像生成的语句，
% 某些功能由于太占空间封装到函数里面了，详情查看大注释。


%% 信号项和干扰项在WVD和模糊域的示例
clear all; close all; clc;
Fs = 100;N=256; %单位对应MHz, us
s1 = fmconst(N,0.07,1) + fmlin(N,0.2,0.4,1);%tfrspwv(s);
QTFR_Compare_autoTerm_corssTerm(s1,N,Fs);%2LFM的交叉项展示
s2 = fmconst(N,0.07,1) + fmsin(N,0.2,0.4,N*2,1,0.35);%tfrspwv(s);
QTFR_Compare_autoTerm_corssTerm(s2,N,Fs);%2LFM的交叉项展示


pause
%% 不同核在不同参数下的表现
QTFR_Compare_different_Kernels();


pause
%% 不同核下的QTFR对比
% QTFR_Compare_Separable_kernels_thesis();%不是可分离核
QTFR_Compare_different_Kernels_tfr();
QTFR_Compare_different_Kernels_perference();


pause
%% 计算DGF旋转核在不同角度下的通带特性
clear all; close all; clc
N=83; %核大小
endAngle=180; stepAngle=45;%总的角度和角度梯度
a = 2; b = 12; %核参数
[x,y]=meshgrid(-1:2/N:1,-1:2/N:1); %核xy值产生
KerCell = cell(endAngle/stepAngle,1);
for k=0:endAngle/stepAngle-1
    angle=pi*k*stepAngle/endAngle;%当前旋转角度
    
    xr=x*cos(angle)-y*sin(angle);%公式52下面的t_theta和f_theta
    yr=x*sin(angle)+y*cos(angle);
    
    ker=exp((-1/2)*(((a*xr).^2)+(b*yr).^2));%式52计算导数后可得
    ker=ker.*(1-b*b*yr.^2);
    ker=ker/sum(sum(abs(ker)));
    KerCell{k+1} = ker;
    
    % % 调试语句--查看旋转DGF核
    % imagesc(BB{kk+1});pause(0.01)
    figure;imagesc(KerCell{k+1});axis off;colormap('hot');
end


pause
%% 不同TFR与ADTFR的对比
clear all; close all;clc
Fs = 100;N=256; %单位对应MHz, us
t = (0:(N-1))/Fs; f = linspace(0,Fs/2,N);
s = fmsin(N,0.1,0.3) + fmlin(N,0.35,0.1,128);
s = awgn(s,50,'measured'); %%%%%%% 信噪比设置
TFD_WVD=quadtfd(s,N-1,1,'wvd',N);
TFD_SPEC = quadtfd(s, N-1, 1, 'specx', 51, 'hamm',N);
% TFD_SM = quadtfd(s,N-1,1,'smoothed',51, 'hamm',N);
% TFD_EMBD=quadtfd(s,N-1,1,'emb',0.3,0.3,N);
TFD_CKD=tfrCKD(s);
TFD_AOK = tfrAOK(s);
TFD_AFS=tfrAFS(s);
TFD_ADTFD = tfrADTFD(s, 3, 12, 82);
figure('Name','TFD_WVD');imagesc(t,f,abs(TFD_WVD));axis xy;set_gca_style([5,5]);axis off;set(gca, 'position', [0 0 1 1 ]);
figure('Name','TFD_SPEC');imagesc(t,f,abs(TFD_SPEC));axis xy;set_gca_style([5,5]);axis off;set(gca, 'position', [0 0 1 1 ]);
figure('Name','tfrCKD');imagesc(t,f,abs(TFD_CKD));axis xy;set_gca_style([5,5]);axis off;set(gca, 'position', [0 0 1 1 ]);
figure('Name','TFD_AOK');imagesc(t,f,abs(TFD_AOK));axis xy;set_gca_style([5,5]);axis off;set(gca, 'position', [0 0 1 1 ]);
figure('Name','TFD_AFS');imagesc(t,f,abs(TFD_AFS));axis xy;set_gca_style([5,5]);axis off;set(gca, 'position', [0 0 1 1 ]);
figure('Name','TFD_ADTFD');imagesc(t,f,abs(TFD_ADTFD));axis xy;set_gca_style([5,5]);axis off;set(gca, 'position', [0 0 1 1 ]);
RWVD=sum(abs(TFD_WVD(:))>0.1*max(abs(TFD_WVD(:))))/N.^2
RSPEC=sum(abs(TFD_SPEC(:))>0.1*max(abs(TFD_SPEC(:))))/N.^2
RCKD=sum(abs(TFD_CKD(:))>0.1*max(abs(TFD_CKD(:))))/N.^2
RAOK=sum(abs(TFD_AOK(:))>0.1*max(abs(TFD_AOK(:))))/N.^2
RAFS=sum(abs(TFD_AFS(:))>0.1*max(abs(TFD_AFS(:))))/N.^2
RADTFD=sum(abs(TFD_ADTFD(:))>0.1*max(abs(TFD_ADTFD(:))))/N.^2









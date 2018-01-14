%% 无噪声环境下多FM分量信号TFR对比

clear all; close all;clc
Fs = 100;N=256; %单位对应MHz, us
t = (0:(N-1))/Fs; f = linspace(0,Fs/2,N);
s = fmsin(N,0.1,0.3) + fmlin(N,0.35,0.1,128);

% s = awgn(s,0,'measured'); %%%%%%% 信噪比设置

TFD_WVD=quadtfd(s,N-1,1,'wvd',N);
TFD_SPEC = quadtfd(s, N-1, 1, 'specx', 51, 'hamm',N);
% TFD_SM = quadtfd(s,N-1,1,'smoothed',51, 'hamm',N);
% TFD_EMBD=quadtfd(s,N-1,1,'emb',0.3,0.3,N);
TFD_CKD=tfrCKD(s);
TFD_AOK = tfrAOK(s);
TFD_AFS=tfrAFS(s);
TFD_ADTFD = tfrADTFD(s, 3, 12, 82);
figure('Name','TFD_WVD');imagesc(t,f,abs(TFD_WVD));axis xy;%set_gca_style([5,5]);axis off;set(gca, 'position', [0 0 1 1 ]);
figure('Name','TFD_SPEC');imagesc(t,f,abs(TFD_SPEC));axis xy;%set_gca_style([5,5]);axis off;set(gca, 'position', [0 0 1 1 ]);
figure('Name','tfrCKD');imagesc(t,f,abs(TFD_CKD));axis xy;%set_gca_style([5,5]);axis off;set(gca, 'position', [0 0 1 1 ]);
figure('Name','TFD_AOK');imagesc(t,f,abs(TFD_AOK));axis xy;%set_gca_style([5,5]);axis off;set(gca, 'position', [0 0 1 1 ]);
figure('Name','TFD_AFS');imagesc(t,f,abs(TFD_AFS));axis xy;%set_gca_style([5,5]);axis off;set(gca, 'position', [0 0 1 1 ]);
figure('Name','TFD_ADTFD');imagesc(t,f,abs(TFD_ADTFD));axis xy;%set_gca_style([5,5]);axis off;set(gca, 'position', [0 0 1 1 ]);
RWVD=sum(abs(TFD_WVD(:))>0.1*max(abs(TFD_WVD(:))))/N.^2
RSPEC=sum(abs(TFD_SPEC(:))>0.1*max(abs(TFD_SPEC(:))))/N.^2
RCKD=sum(abs(TFD_CKD(:))>0.1*max(abs(TFD_CKD(:))))/N.^2
RAOK=sum(abs(TFD_AOK(:))>0.1*max(abs(TFD_AOK(:))))/N.^2
RAFS=sum(abs(TFD_AFS(:))>0.1*max(abs(TFD_AFS(:))))/N.^2
RADTFD=sum(abs(TFD_ADTFD(:))>0.1*max(abs(TFD_ADTFD(:))))/N.^2


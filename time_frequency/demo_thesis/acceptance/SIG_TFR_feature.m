% 采样频率100MHz，幅度1V
% 本脚本文件包含所有【时频分析理论章节】相关图像生成的语句，
% 某些功能由于太占空间封装到函数里面了，详情查看大注释。


%% LFM+SFM 的 时频特性分析
clear all; close all;clc
Fs = 100;N=256; %单位对应MHz, us
t = (0:(N-1))/Fs; f = linspace(0,Fs/2,N);
s1 = fmsin(N,0.1,0.3);
s2 = fmlin(N,0.35,0.1,128);
s = s1 + s2;
% s = awgn(s,50,'measured'); %%%%%%% 信噪比设置

figure;imagesc(abs(tfrstft(s1)));axis xy;
% set_gca_style([5,5]);axis off;set(gca, 'position', [0 0 1 1 ]);
figure;imagesc(abs(tfrstft(s2)));axis xy;
% set_gca_style([5,5]);axis off;set(gca, 'position', [0 0 1 1 ]);
figure;imagesc(abs(tfrstft(s)));axis xy;
% set_gca_style([5,5]);axis off;set(gca, 'position', [0 0 1 1 ]);


%% LFM+SFM 的 时频特性分析
clear all; clc
Fs = 100;N=256; %单位对应MHz, us
t = (0:(N-1))/Fs; f = linspace(0,Fs/2,N);
s1 = fmsin(N,0.1,0.3,512);
s2 = fmlin(N,0.35,0.1,1);
s = s1 + s2;
% s = awgn(s,50,'measured'); %%%%%%% 信噪比设置

figure;imagesc(abs(tfrstft(s1)));axis xy;
% set_gca_style([5,5]);axis off;set(gca, 'position', [0 0 1 1 ]);
figure;imagesc(abs(tfrstft(s2)));axis xy;
%set_gca_style([5,5]);axis off;set(gca, 'position', [0 0 1 1 ]);
figure;imagesc(abs(tfrstft(s)));axis xy;
% set_gca_style([5,5]);axis off;set(gca, 'position', [0 0 1 1 ]);

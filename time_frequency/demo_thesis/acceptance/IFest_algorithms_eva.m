% 采样频率100MHz，幅度1V
% 本脚本文件包含所有【瞬时频率估计章节】相关图像生成的语句，
% 某些功能由于太占空间封装到函数里面了，详情查看大注释。


%% 时频无重叠三分量信号-IF估计算法对比
clear all; clc; close all;
Fs = 100;N=256; %单位对应MHz, us
t = (0:(N-1))/Fs; f = linspace(0,Fs/2,N);
[s1, sif1] = fmlin(N,0.03,0.09);
[s2, sif2] = fmlin(N,0.31,0.5);
[s3, sif3] = fmsin(N,0.15,0.28,300);
s_org = s1+s2+s3;%tfr = tfrstft(s_org);imagesc(abs(tfr));axis xy
s = awgn(s_org,10,'measured');
tfr = tfrADTFD(s,3,20,82);%imagesc(tfr);axis xy
tfr_emb = quadtfd(s, 127, 1, 'emb', 0.1, 0.3, N);%imagesc(tfr_emb);axis xy
[hif1,hif2] = IFest_compare_algorithm(tfr_emb.',10,20,3,75);%对比算法性能的脚本函数
[hif3s] = IFest_proposed(tfr,10,20,3,75,2,7);%使用hif1增强计算提出的优化算法
for n=1:length(hif3s) ; hif3{n} = hif3s{n}.line; end

% 结果绘制
figure('Name','IF algorithms compare');F_scale = Fs/N/2;
for n=1:length(hif1) ;   hmcq=plot(hif1{n}(1:8:end,1)/Fs,hif1{n}(1:8:end,2)*F_scale,'ko-','MarkerSize',6); hold on; end   %绘制IF曲线
for n=1:length(hif2) ;   hlr=plot(hif2{n}(2:8:end,1)/Fs,hif2{n}(2:8:end,2)*F_scale,'bsquare-','MarkerSize',3); hold on; end   %绘制IF曲线
for n=1:length(hif3) ;   henmcq=plot(hif3{n}(3:8:end,1)/Fs,hif3{n}(3:8:end,2)*F_scale,'rp-','MarkerSize',6); hold on; end   %绘制IF曲线
legend([hlr hmcq henmcq],{'LPDCL','BDIF','proposed'}); %set_gca_style([6,6]);grid off; ylim([0,60]);%方便放置图例
xlabel('时间/\mus');ylabel('频率/Mhz');

hiferr = Fs * IFest_perferenceEva({hif1,hif2,hif3},[sif1,sif2,sif3],N)
%无重叠情况下稍微好,100M采样率下平均误差才0.4M算什么水平？可以解释为频率分辨率本身就很低
% （100M有256采样点说白了就一个像素点的问题）


pause(5)
%% 时频有重叠三分量信号-IF估计算法对比
clear all; 
Fs = 100;N=256; %单位对应MHz, us
t = (0:(N-1))/Fs; f = linspace(0,Fs/2,N);
[s1, sif1] = fmlin(N,0.05,0.2, 5);
[s2, sif2] = fmlin(N,0.35,0.09,1);
[s3, sif3] = fmsin(N,0.15,0.28,300);
s_org = s1+s2+s3;
s = awgn(s_org,20,'measured');
tfr = tfrADTFD(s,2,15,82);%imagesc(abs(tfr));axis xy
tfr_emb = quadtfd(s, 127, 1, 'emb', 0.1, 0.3, N); %imagesc(tfr_emb);axis xy
[hif1,hif2] = IFest_compare_algorithm(tfr_emb.',10,20,3,75);%对比算法性能的脚本函数
[hif3s] = IFest_proposed(tfr,10,20,3,75,2,7);%使用hif1增强计算提出的优化算法
for n=1:length(hif3s) ; hif3{n} = hif3s{n}.line; end

% 结果绘制
figure('Name','IF algorithms compare');F_scale = Fs/N/2;
for n=1:length(hif1) ;   hmcq=plot(hif1{n}(1:8:end,1)/Fs,hif1{n}(1:8:end,2)*F_scale,'ko-','MarkerSize',6); hold on; end   %绘制IF曲线
for n=1:length(hif2) ;   hlr=plot(hif2{n}(2:8:end,1)/Fs,hif2{n}(2:8:end,2)*F_scale,'bsquare-','MarkerSize',3); hold on; end   %绘制IF曲线
for n=1:length(hif3) ;   henmcq=plot(hif3{n}(3:8:end,1)/Fs,hif3{n}(3:8:end,2)*F_scale,'rp-','MarkerSize',6); hold on; end   %绘制IF曲线
legend([hlr hmcq henmcq],{'LPDCL','BDIF','proposed'}); %set_gca_style([6,6]);grid off; ylim([0,60]);%方便放置图例
xlabel('时间/\mus');ylabel('频率/Mhz');

hiferr = Fs * IFest_perferenceEva({hif1,hif2,hif3},[sif1,sif2,sif3],N)
% 针对这种重叠不严重的也只能说还好，不算太差



pause(5)
%% 其它信号IF估计结果
clear all; 
Fs = 100;N=256; %单位对应MHz, us
t = (0:(N-1))/Fs; f = linspace(0,Fs/2,N);
[s1,sif1]=fmsin(N,0.1,0.4,128,1,0.1,1);%(N,FNORMIN,FNORMAX,PERIOD,T0,FNORM0,PM1)
[s2,sif2]=fmsin(N,0.1,0.4,128,1,0.4,1);%(N,FNORMIN,FNORMAX,PERIOD,T0,FNORM0,PM1)
s_org = s1+s2; 
s = awgn(s_org,100,'measured');
tfr = tfrADTFD(s,3,20,82);%
[hif1,hif2] = IFest_compare_algorithm(tfr.',10,20,2,75);%对比算法性能的脚本函数
[hif3s] = IFest_proposed(tfr,10,20,2,75,2,5);%使用hif1增强计算提出的优化算法
for n=1:length(hif3s) ; hif3{n} = hif3s{n}.line; end

% 结果绘制
figure('Name','IF algorithms compare');F_scale = Fs/N/2;
for n=1:length(hif1) ;   hmcq=plot(hif1{n}(1:8:end,1)/Fs,hif1{n}(1:8:end,2)*F_scale,'ko-','MarkerSize',6); hold on; end   %绘制IF曲线
for n=1:length(hif2) ;   hlr=plot(hif2{n}(2:8:end,1)/Fs,hif2{n}(2:8:end,2)*F_scale,'bsquare-','MarkerSize',3); hold on; end   %绘制IF曲线
for n=1:length(hif3) ;   henmcq=plot(hif3{n}(3:8:end,1)/Fs,hif3{n}(3:8:end,2)*F_scale,'rp-','MarkerSize',6); hold on; end   %绘制IF曲线
legend([hlr hmcq henmcq],{'LPDCL','BDIF','proposed'}); %set_gca_style([6,6]);grid off; ylim([0,60]);%方便放置图例
xlabel('时间/\mus');ylabel('频率/Mhz');

hiferr = Fs * IFest_perferenceEva({hif1,hif2,hif3},[sif1,sif2],N)
% 这对这种重叠严重的就具有非常巨大的改进效果了














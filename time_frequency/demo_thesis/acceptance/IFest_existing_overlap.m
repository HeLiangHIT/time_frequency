%% 时频无重叠三分量信号-IF估计算法对比
clear all; clc; close all;
Fs = 100;N=256; %单位对应MHz, us
t = (0:(N-1))/Fs; f = linspace(0,Fs/2,N);
[s1, sif1] = fmlin(N,0.05,0.2);
[s2, sif2] = fmlin(N,0.35,0.09);
[s3, sif3] = fmsin(N,0.15,0.28,300);
s_org = s1+s2+s3;%  tfr = tfrstft(s_org);imagesc(abs(tfr));axis xy

s = awgn(s_org,5,'measured');%%%%%%%%% 5, 0, -5

tfr = quadtfd(s, 127, 1, 'emb', 0.1, 0.3, N)';
[hif1,hif2] = IFest_compare_algorithm(tfr,10,20,3,75);%对比算法性能的脚本函数
% 结果绘制
figure('Name','TFR'); himg = imagesc(t,f,tfr');%set_gca_style([6,6]);grid off; colormap('hot');
xlabel('时间/\mus');ylabel('频率/Mhz');axis on;axis xy;
figure('Name','IF algorithms compare');F_scale = Fs/N/2;
for n=1:length(hif1) ;   hmcq=plot(hif1{n}(1:5:end,1)/Fs,hif1{n}(1:5:end,2)*F_scale,'ro-','MarkerSize',6); hold on; end   %绘制IF曲线
for n=1:length(hif2) ;   hlr=plot(hif2{n}(1:5:end,1)/Fs,hif2{n}(1:5:end,2)*F_scale,'bsquare-','MarkerSize',2.5); hold on; end   %绘制IF曲线
legend([hlr hmcq],{'LPDCL','BDIF'}); %set_gca_style([6,6]);grid off; ylim([0,60]);%方便放置图例
xlabel('时间/\mus');ylabel('频率/Mhz');


tfr = tfrADTFD(s,2,15,82)';
[hif1,hif2] = IFest_compare_algorithm(tfr,10,20,3,75);%对比算法性能的脚本函数
% 结果绘制
figure('Name','TFR'); himg = imagesc(t,f,tfr');%set_gca_style([6,6]);grid off; colormap('hot');
xlabel('时间/\mus');ylabel('频率/Mhz');axis on;axis xy;
figure('Name','IF algorithms compare');F_scale = Fs/N/2;
for n=1:length(hif1) ;   hmcq=plot(hif1{n}(1:5:end,1)/Fs,hif1{n}(1:5:end,2)*F_scale,'ro-','MarkerSize',6); hold on; end   %绘制IF曲线
for n=1:length(hif2) ;   hlr=plot(hif2{n}(1:5:end,1)/Fs,hif2{n}(1:5:end,2)*F_scale,'bsquare-','MarkerSize',2.5); hold on; end   %绘制IF曲线
legend([hlr hmcq],{'LPDCL','BDIF'}); %set_gca_style([6,6]);grid off; ylim([0,60]);%方便放置图例
xlabel('时间/\mus');ylabel('频率/Mhz');
% axis([1.1,2.1,12,25]);



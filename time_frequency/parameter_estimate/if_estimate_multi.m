%% 参考代码地址：https://github.com/otoolej/time_frequency_tracks

%% 信号产生
clear all; clc, close all;
N=512;
Fs = 100e6;
MIN_LEN = 20;%最短IF片段长度
IF_NUMBER = 3;%IF片段数量
s = fmlin(N,0.01,0.05) + fmlin(N,0.1,0.16) + fmlin(N,0.2,0.5);
% s = fmsin(N,0.1,0.3,400,400,0.2) + fmlin(N,0.05,0.4);
% s = fmsin(N,0.1,0.25,200);
x = awgn(s,0,'measured');
%% 计算TFD
% tf1 = full_tfd(real(x),'sep',{{51,'hann'},{51,'hann'}},N,N);% tf1 = dec_tfd(x,'sep',{{51,'hann'},{51,'hann'}},512,512,1,1);
%前一个窗越长，则垂直方向能量越集中，但是干扰越大；后一个窗越长，水平方向能量越集中，但是干扰越大。
tf2 = quadtfd(x, 127, 1, 'emb', 0.1, 0.3, N)';% tf2 = tfrspwv(x); %第二个参数也影响干扰
% subplot(121),imagesc(tf1');axis xy;subplot(122),imagesc(tf2');axis xy;
tf = tf2;% tf = abs(tfrspwv(x))';
t_scale=(1/Fs);  f_scale=(Fs/2)/size(tf,2); %绘图用的归一化参数

%% Rankine et al. (2007) method: 改进之后，增加了低于部分的能量滤除
delta_freq_samples= 10;%IF追踪的梯度，设置最大为10个图像距离
min_track_length=MIN_LEN;%最短跟踪IF片段长度
lower_prctile_limit = 60; % 忽略低于该能量的百分比
it=tracks_LRmethod(tf,1,delta_freq_samples,min_track_length,lower_prctile_limit);%这里设置Fs=1方便设置上面三个参数为图像参数

%% McAulay and Quatieri (1986) method:
max_peaks=IF_NUMBER;%每个时刻最大的重复IF数量
it2=tracks_MCQmethod(tf,Fs,delta_freq_samples,min_track_length,max_peaks);

%% HRV CPL IF estimation--其实就是2007年那种方法的另一个写法
tfps = tfdpeaks(tf', 2);%第二个参数是peaks的百分比，越小检测出的峰值越多
[it3_r, cps] = edgelink3(tfps,20); %第二个参数是最短边缘长度

% 绘图
figure(1); clf; hold all; 
for n=1:length(it)
    %hlr=plot(it{n}(:,1).*t_scale,filt_if_law(it{n}(:,2).*f_scale),'k+-');%滤波会导致边缘偏差
    hlr=plot(it{n}(:,1).*t_scale,it{n}(:,2).*f_scale,'ko-'); 
end
for n=1:length(it2)
    %hmcq=plot(it2{n}(:,1).*t_scale,filt_if_law(it2{n}(:,2).*f_scale),'rx-'); 
    hmcq=plot(it2{n}(:,1).*t_scale,it2{n}(:,2).*f_scale,'r+-'); 
end
for n = 1:length(it3_r)
    %hhrv=plot(it3_r{n}(:,2).*t_scale,filt_if_law(it3_r{n}(:,1).*f_scale),'b.-'); 
    hhrv=plot(it3_r{n}(:,2).*t_scale,it3_r{n}(:,1).*f_scale,'bx-'); 
end
xlabel('time (seconds)'); ylabel('frequency (Hz)');axis tight
legend([hlr hmcq hhrv],{'LR method','MCQ method','HRV CPL method'},'location','northwest');
set_gca_style()







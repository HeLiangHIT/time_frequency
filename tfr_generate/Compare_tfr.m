%% 对比一些先进的时频分布
% 在高SNR下 tfrADTFD 确实表现很优秀，但是在低SNR下 tfrADTFD 表现就很差了，因为噪声也被它选择性的放大了。
% 高分辨率自适应窗的代价就是对噪声的鲁棒性不那么好！！

clc; clear; close all;warning('off','signal:hilbert:Ignore')
%% 作者设计的信号下分布对比
% 两个平行的固定频率信号和两个平行的LFM信号叠加，间距都很小
% x1=gsig('lin', 0.05, 0.05, 256,0); %tone
% x2=gsig('lin', 0.1, 0.1, 256,0);%tone
% x3=gsig('lin', 0.3, 0.4, 256,0);%chirp
% x4=gsig('lin', 0.35, 0.45, 256,0);%chirp
% x=(x1+x2+x3+x4); %叠加

% 两个平行二次分布的信号和两个LFM信号组合
t=0:255;
x=2*cos(0.1*pi*t+0.000002*pi*t.^3)+2*cos(0.2*pi*t+0.000002*pi*t.^3)+cos(0.6*pi*t+0.0000015*pi*t.^3)+cos(0.9*pi*t-0.0000015*pi*t.^3);

x = awgn(x,50,'measured');%添加噪声

display('Spectrogram');
TFD_SPEC = quadtfd( x, length(x)-1, 1, 'specx', 65, 'hamm',256);
figure; tfsapl(x,TFD_SPEC,'GrayScale','on', 'Title', 'Spectrogram');

display('Wigner-Ville distribution');
TFD_WVD=quadtfd(x,255,2,'wvd',256);
figure; tfsapl(x,TFD_WVD,'GrayScale','on', 'Title', 'WVD');

display('Extended Modified B distribution');
TFD_EMBD=quadtfd(x,155,2,'emb',0.5,0.5,256);
figure; tfsapl(x,TFD_EMBD,'GrayScale','on', 'Title', 'EMBD');
% %具体实现方式等效如下：WVD谱的FFT和窗函数相乘，实现WVD二维频域滤波
% wvdz=wvd(x,length(x)-1,1,2^nextpow2(length(x)));
% g=extnd_mbd(0.07,0.15,1,length(x));
% gsig=ifft(fft(wvdz.').');
% smg=gsig.*g;
% EMBD=real(fft(ifft(smg.').'));
% EMBD=imresize(EMBD,[length(x) length(x)]);
% EMBD(EMBD<0)=0;

display('Compact Kernel distribution');
TFD_CKD=tfrCKD(x);
TFD_CKD(TFD_CKD<0)=0;
figure; tfsapl(x,real(TFD_CKD),'GrayScale','on','Title','Compact Kernel Distribution');

display('Adaptive fractional Spectrogram');
TFD_AFS=tfrAFS(hilbert(x));
figure; tfsapl(x,TFD_AFS,'GrayScale','on','Title','Adaptive fractional Spectrogram' );

display('AOK-TFD');
I_max_new = tfrAOK(x);
TFD_AOK=real(I_max_new);
figure; tfsapl(x,TFD_AOK,'GrayScale','on','Title','AOK-TFD');

display('Adaptive direction TFD');
TFD_ADTFD = tfrADTFD(x, 3,12,82);
TFD_ADTFD(TFD_ADTFD<0)=0;
TFD_ADTFD=imresize(TFD_ADTFD,[length(x) length(x)]);
figure; tfsapl(x,TFD_ADTFD,'GrayScale','on','Title', 'Adaptive direction TFD');

pause
%% 自定义信号下分布的对比
clear all; close all;
N = 256;
s = fmsin(N,0.1,0.3) + fmlin(N,0.35,0.1,128);
s = awgn(s,5,'measured');
TFD_SPEC = quadtfd(s, N-1, 1, 'specx', 51, 'hamm',N);
TFD_WVD=quadtfd(s,N-1,1,'wvd',N);
TFD_SM = quadtfd(s,N-1,1,'smoothed',51, 'hamm',N);
TFD_EMBD=quadtfd(s,N-1,1,'emb',0.3,0.3,N);
TFD_CKD=tfrCKD(s);
TFD_AFS=tfrAFS(s);
TFD_AOK = tfrAOK(s);
TFD_ADTFD = tfrADTFD(s, 3, 12, 82);
figure('Name','传统时频优化方案');
subplot(221); imagesc(abs(TFD_SPEC));axis xy;title('specx');
subplot(222);imagesc(abs(TFD_WVD));axis xy;title('wvd');
subplot(223); imagesc(abs(TFD_SM));axis xy;title('smoothed');
subplot(224); imagesc(abs(TFD_EMBD));axis xy;title('emb');
figure('Name','自适应时频优化方案');
subplot(221); imagesc(abs(TFD_CKD));axis xy;title('CKD');
subplot(222);imagesc(TFD_AFS);axis xy;title('AFS');%STFRFT的类似形式
subplot(223); imagesc(TFD_AOK);axis xy;title('AOK');%局部方向优化，适合单分量信号
subplot(224);imagesc(TFD_ADTFD);axis xy;title('ADTFD');
% 由此参数可见如果信号相位叠加影响太严重，ADTFD也没法改善，这是整个QTFD的缺陷。
% 使用自适应的STFRFT也许可以改善，从AFS里面可以看出其实还是改善了很多的，不过AFS提取的极大值太多了。


% 结合两种方法提出的改进算法
TFD_AFS_ADTFD = tfrAFS_ADTFD(s, 2,12,82);%tfrMyADTFD(s, 2,12,82);tfrADTFD(s, 2, 30, 82);
figure;imagesc(TFD_AFS);axis xy;title('AFS');%STFRFT的类似形式
figure;imagesc(TFD_ADTFD);axis xy;title('ADTFD');
figure;imagesc(TFD_AFS_ADTFD);axis xy;title('MyADTFD');%显然必须让我的参数实现的效果最好










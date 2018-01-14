%% 能量分布，第二类解决方案。

%% Cohen类
%% 1、Wigner-Ville distribution
clear all; close all; clc;
sig=fmlin(256);tfrwv(sig);%可以看出WVD分布具有非常完美的视频局部特性，其值可能为负数
[fm,am,iflaw]=doppler(256,50,13,10,200);%多普勒信号
% [调频信号，幅度分量，瞬时频率law] = [采样点数，采样频率，目标频率，目标距离，目标速度，中心时间]
sig=am.*fm; tfrwv(sig);%可以看出交叉干扰分量非常多
sig=fmlin(128,0,0.3)+fmlin(128,0.2,0.5);tfrwv(sig);%可以看出存在交叉干扰分量
% 其干扰项规律查看:Oscillating structure of the interferences of the WVD
M=movwv2at(256);%可以修改movwv2at函数的第二个参数控制过渡数量
figure;clf; movie(M,10);
% 可以看出随着距离增加和方向变化时干扰项的演变很有规律

%% 2、对比WVD和PWVD的可视性
clear all; close all; clc;
sig=atoms(128,[32,.15,20,1;96,.15,20,1;...
                    32,.35,20,1;96,.35,20,1]);%产生四个原子的信号[t1,f1,T1,A1]
figure,tfrwv(sig);%6个干扰项的叠加
figure,tfrpwv(sig);%消除了4个横向的干扰项

%% 3、WVD的采样率考虑，使用解析信号的好处
clear all; close all; clc;
sig=atoms(128,[32,0.15,20,1;96,0.32,20,1]);
figure,tfrwv(real(sig));%刚好满足采样率的实数信号的WVD
figure,tfrwv(sig);

%% 4、smoothed-pseudo Wigner-Ville distribution
clear all; close all; clc;
sig=fmconst(128,.15) + amgauss(128).*fmconst(128,0.4);%两个信号的叠加
tfr_wvd=tfrwv(sig); subplot(131);imagesc(tfr_wvd);axis xy; title('WVD');
tfr_pwvd=tfrpwv(sig);subplot(132);imagesc(tfr_pwvd);axis xy;title('PWVD');
tfr_spwvd = tfrspwv(sig);subplot(133);imagesc(tfr_spwvd);axis xy;title('SPWVD');
% 查看SPWVD从功率谱退化到WVD的过程，那么当视频分辨率控制改变时
M=movsp2wv(128);% 可以修改movsp2wv函数的第二个参数控制过渡数量
movie(M,10);

%% 5、narrow-band ambiguity function
clear all; close all; clc;
N=64; %产生两个LFM*高斯衰减信号叠加
sig1=fmlin(N,0.2,0.5).*amgauss(N);
sig2=fmlin(N,0.3,0).*amgauss(N);
sig=[sig1;sig2];%组合信号
figure(1);tfrwv(sig);%两个信号项，中间一些震荡的干扰
figure(2);ambifunb(sig);%求AF谱，中间是信号项，两边是干扰，干扰项远离信号项了
% 可以看出如果在AF域进行2D低通滤波去除四周的干扰项之后，再变回WVD域就可以去除干扰了。
% 事实上cohen类中的参数化函数f就是执行了这个操作。

%% 6、其它Cohen类
clear all; close all; clc;
sig=atoms(128,[32,0.15,20,1;96,0.32,20,1]);
figure(1);tfrmh(sig);%Margenau-Hill,可以看到两个点的干扰项是其xy坐标的交换，不建议
figure(2);tfrri(sig);%Rihaczek,同上
figure(3);tfrpmh(sig);%pseudo Margenau-Hill,可以看到干扰项被消除了很多
figure(4);tfrpage(sig);%Page distribution
figure(5);tfrppage(sig);%pseudo-Page distribution
M=movcw4at(128);clf; movie(M,5);%Choi-Williams distribution的干扰项观察
figure(6);tfrbj(sig);%tfrzam Born-Jordan
figure(7);tfrzam(sig);%Zhao-Atlas-Marks

%% 7、参数化函数的比较
clear all; close all; clc;
N=128; 
x1=fmlin(N,0.05,0.15); x2=fmlin(N,0.2,0.5);
x=x1+x2;%信号叠加
n=noisecg(N);%无色的AWGN噪声
sig=sigmerge(x,n,10); %信号叠加
% WVD及其AF
tfr_wvd = tfrwv(sig);figure
subplot(122);imagesc(abs(tfr_wvd));axis xy
amf_wvd = fftshift(fft2(tfr_wvd));%前面说了AF函数实际上就是WVD变换的二维傅立叶变换
amf_wvd = imrotate(amf_wvd,-90);%不知道为什么需要旋转90度才对
subplot(121);imagesc(abs(amf_wvd));axis xy
% 功率谱及其AF
tfr_spec = tfrsp(sig,1:N,N,gausswin(63));figure
subplot(122);imagesc(abs(tfr_spec));axis xy
amf_spec = fftshift(fft2(tfr_spec));%前面说了AF函数实际上就是WVD变换的二维傅立叶变换
amf_spec = imrotate(amf_spec,-90);%不知道为什么需要旋转90度才对
subplot(121);imagesc(abs(amf_spec));axis xy
% SPWVD及其AF
tfr_spwvd = tfrspwv(sig);figure
subplot(122);imagesc(abs(tfr_spwvd));axis xy
amf_spwvd = fftshift(fft2(tfr_spwvd));%前面说了AF函数实际上就是WVD变换的二维傅立叶变换
amf_spwvd = imrotate(amf_spwvd,-90);%不知道为什么需要旋转90度才对
subplot(121);imagesc(abs(amf_spwvd));axis xy
% BJ及其AF
tfr_bj = tfrbj(sig);figure
subplot(122);imagesc(abs(tfr_bj));axis xy
amf_bj = fftshift(fft2(tfr_bj));%前面说了AF函数实际上就是WVD变换的二维傅立叶变换
amf_bj = imrotate(amf_bj,-90);%不知道为什么需要旋转90度才对
subplot(121);imagesc(abs(amf_bj));axis xy
% Choi-Williams 及其AF
tfr_cw = tfrzam(sig);figure
subplot(122);imagesc(abs(tfr_cw));axis xy
amf_cw = fftshift(fft2(tfr_cw));%前面说了AF函数实际上就是WVD变换的二维傅立叶变换
amf_cw = imrotate(amf_cw,-90);%不知道为什么需要旋转90度才对
subplot(121);imagesc(abs(amf_cw));axis xy

%% affine类
%% 1、scalogram 依赖频率值的平滑效果显示
clear all; close all; clc;
sig=atoms(128,[38,0.1,32,1;96,0.35,32,1]);
figure, tfrscalo(sig);%The scalogram
% 可见频率越低时宽越宽，频率越高时宽越窄。
% 使用ASPWVD查看量图到WVD的退化
M=movsc2wv(128);
clf; movie(M,10);%可以看到其变换过程中时域平滑和频率值有关
%WVD的视频分辨率最高，但是存在干扰；量图分辨率最低，但是几乎没有干扰；ASPWVD实现了在两者之间的折衷。
% 对比量图和谱图通过WVD的过渡
M1=movsc2wv(128);%from the scalogram to the WVD
M2=movsp2wv(128);%from the spectrogram to the WVD
M=[M1,M2(end:-1:1)];%from the scalogram to the spectrogram
clf; movie(M,10);


%% 2、Bertrand distribution
clear all; close all; clc;
sig=gdpower(128);
tfrbert(sig,1:128,0.01,0.22,128,1);%Bertrand distribution
% 该变换具有较好的双曲群延迟局部化，但是并不完美，因为只是频谱的一部分。
sig=gdpower(128,1/2);
tfrdfla(sig,1:128,0.01,0.22,128,1);%D-Flandrin distribution
% 该变换针对根号反比的群延时函数局部化较好。
sig=gdpower(128,-1);
tfrunter(sig,1:128,'A',0.01,0.22,172,1);%Unterberger distributions
% 改变后针对平方反比的群延时函数局部化较好。

%% 3、宽带信号分析
clear all; close all; clc;
sig=anapulse(128);tfrwv(sig);%宽带信号的WVD分析----可见在信号时间领域内局部化并不是很好。
sig=altes(128,0.1,0.45);ambifuwb(sig);%宽带AF变换
% WAF将模糊平面最大化了。


%% 4、affine Wigner distributions在不同k值下的干扰结构，
clear all; close all; clc;
K=-15:20;%随意指定的K范围
for k=1:length(K)
    [t(k),f(k)]=midpoint(10,0.45,60,0.05,K(k));%计算不同k值时的Affine类分布中心点
end
plot(t,f,'r.-',[10,60],[0.45,0.05],'o-');%绘制干扰结构和原始两个时频点
% 为了显示干扰集合结构，下面产生一个SIN调频信号
[sig,ifl]=fmsin(128);%产生sin调频信号
% 在给定if下构造affine Wigner分布的干扰
figure;plotsid(1:128,ifl,0);%Bertrand distribution (k = 0) 
figure;plotsid(1:128,ifl,2);%Wigner-Ville distribution (k = 2)
figure;plotsid(1:128,ifl,-1);%Unterberger distribution(k=-1)
figure;tfrspwv(sig);%WVD分析一下信号较好。


%% 5、不同的k值下affine类分布的时频分析
clear all; close all; clc;
load bat; N=128;
sig=hilbert(bat(801:7:800+N*7)').';%产生解析信号用于分析
% 对不同的k值计算对应的affine Wigner distribution和affine smoothed pseudo Wigner distribution
figure,tfrwv(sig);%K=2是是WVD，由于调频非线性导致了干扰项
figure,tfrspaw(sig,1:N,2,24,0,0.1,0.4,N,1);%K=2，基本抑制了干扰项
figure,tfrbert(sig,1:N,0.1,0.4,N,1);%k=0时是pseudo Bertrand distribution，近似双曲线时延特性对该信号展现了非常好的描述，但是依然存在部分干扰
figure,tfrspaw(sig,1:N,0,32,0,0.1,0.4,N,1);%k=0，基本消除了所有干扰


%% 6、reassigned spectrogram的时频分布改进
clear all; close all; clc;
N=128; 
[sig1,ifl1]=fmsin(N,0.15,0.45,100,1,0.4,-1);%SIN频率调制
[sig2,ifl2]=fmhyp(N,[1 .5],[32 0.05]);%双曲频率调制
sig=sig1+sig2;
tfrideal([ifl1 ifl2]);%根据频率信息绘制完美的TF分布
figure; tfrrsp(sig);%计算reassigned spectrogram
% 一大波证明reassignment优势（增强时频分布的局部化特性）的测试
[sig1,ifl1]=fmsin(60,0.15,0.35,50,1,0.35,1);
[sig2,ifl2]=fmlin(60,0.3,0.1);
[sig3,ifl3]=fmconst(60,0.4);
sig=[sig1;zeros(8,1);sig2+sig3];%信号组合
iflaw=zeros(128,2);
iflaw(:,1)=[ifl1;NaN*ones(8,1);ifl2];
iflaw(:,2)=[NaN*ones(68,1);ifl3];%频率组合
tfrideal(iflaw);%理想信号时频分布
figure; tfrwv(sig);%信号的WVD分布，信号是局部化很好，但是很多交叉项让时频分布很难读。
figure;tfrrpwv(sig);%PWVD在时间轴去掉了交叉项，但是依然存在交叉项，导致reassigned后还是看得到交叉项
figure; tfrrspwv(sig);%  SPWVD and its reassigned version,性能非常好
%可见SPWVD确实通过平滑去除了很多交叉项，但是分辨率被减低了很多。通过reassigned后分辨率再次提高。
%%【总之reassigned的好处就是将所有的TF分布组件都局部化，让其趋于理想分布】
figure;tfrrsp(sig);%功率谱及其reassigned----性能较好（无干扰项）
figure;tfrrmsc(sig);%Morlet scalogram及其reassigned----性能较差（也没有干扰项，但在低频部分的时间分辨率严重不足）
figure;tfrrppag(sig);%pseudo-Page，由于干扰项的叠加导致性能很差，几乎拾取意义
figure;tfrrpmh(sig);%pseudo Margenau-Hill，由于干扰项的叠加导致性能很差，几乎拾取意义
%总结起来，还是【使用spectrogram or the SPWVD性能比较好】

%% 7、其它时频抽取方法
clear all; close all; clc;
[sig1,ifl1]=fmsin(60,0.15,0.35,50,1,0.35,1);
[sig2,ifl2]=fmlin(60,0.3,0.1);
[sig3,ifl3]=fmconst(60,0.4);
sig=[sig1;zeros(8,1);sig2+sig3];%信号组合
t=1:2:127; [tfr,rtfr,hat]=tfrrpwv(sig,t);
figure;friedman(tfr,hat,t,'tfrrpwv',1);%时频局部化特性较好
[tfr,rtfr,hat]=tfrrsp(sig);
figure;ridges(tfr,hat);%骨架和边缘提取

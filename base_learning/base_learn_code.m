%% 入门TFTB工具箱学习
% 学习及其注释
% 升级之处：imagesc 可以指定横纵坐标绘制图像

%% 1，基本使用
% 线性调频信号的产生和分析
clear,clc,close all;
N=512;%采样点数
FNORMI = 0;%起始频率->相对于采样频率，between -0.5 and 0.5
FNORMF = 0.5;%结束频率->相对于采样频率，between -0.5 and 0.5
T0 = N/2;%time reference for the phase,相位的参考时间？
[Y,IFLAW]=fmlin(N,FNORMI,FNORMF,T0);
figure('Name','CHIRP信号的时频图像')
subplot(211),plot(real(Y));axis tight;%CHIRP信号
Y_W=fftshift(abs(fft(Y)).^2);%
subplot(212),plot(linspace(-0.5,0.5,N),abs(Y_W));axis tight;%频谱
figure('Name','CHIRP信号的Wigner-Ville分布')
TF_dis = tfrwv(Y);%WV谱
imshow(TF_dis,[]);colormap('hot');axis xy on;%缺陷，使用imshow无法指定横纵坐标值，可以使用surf等
xlabel('t/s'),ylabel('f/Hz');
% 添加噪声后的信号分析
Y_n=sigmerge(Y,noisecg(N),0);%0db
figure('Name','CHIRP+噪声信号的时频图像')
subplot(211),plot(real(Y_n));axis tight;%CHIRP信号
Y_n_W=fftshift(abs(fft(Y_n)).^2);%
subplot(212),plot(linspace(-0.5,0.5,N),abs(Y_n_W));axis tight;%频谱
figure('Name','CHIRP+噪声信号的Wigner-Ville分布')
TF_dis = tfrwv(Y_n);%WV谱
imshow(TF_dis,[]);colormap('hot');axis xy on;%缺陷，使用imshow无法指定横纵坐标值，可以使用surf等
xlabel('t/s'),ylabel('f/Hz');

%% 2、声纳信号的处理
clear,clc,close all;
load bat%采样率为230.4khz
N=length(bat);
t=linspace(0,N/2304,N);
plot(t,bat); xlabel('Time [ms]');
TF_dis = tfrpwv(bat);axis xy%这个函数不支持输入t，否则输出不对
% tfrpwv效果比tfrwv较好
imagesc(abs(TF_dis));axis xy

%% 3、瞬变信号的检测
clear,clc,close all;
N_l=128;N_r=100;
N=N_l+2*N_r;
trans=amexpo1s(N_l).*fmconst(N_l);%幅度exp调制衰减，频率固定
sig=[zeros(N_r,1) ; trans ; zeros(N_r,1)];
sign=sigmerge(sig,noisecg(N),-5);
figure('Name','原始信号的时频序列')
subplot(211),plot(real(sign));
dsp=fftshift(abs(fft(sign)).^2);
subplot(212),plot(linspace(-0.5,0.5,N),dsp);
figure('Name','时频分布图像')
TF_dis = tfrsp(sign);%适用于检测这种频率瞬变信号
imagesc(abs(TF_dis));axis xy


%% 4、时频局部化分析：Heisenberg-Gabor不平等----验证
clear,clc,close all;
N=256;
sig=fmlin(N).*amgauss(N);%AM高斯调制，fm线性调制的信号
[tm,T]=loctime(sig);%时间局部化特征
[num,B]=locfreq(sig);%频率局部化特征
[T,B,T*B]
%次数必须有T*B>1的结论，就是Heisenberg-Gabor inequality定理
sig=amgauss(N);%高斯信号的时频窗T*B=1
[tm,T]=loctime(sig);
[fm,B]=locfreq(sig);
[T,B,T*B]

%% 5、瞬时频率、幅度、群延时
clear,clc,close all;
N=256;
sig=fmlin(N);%线性调频信号
t=(3:N);ifr=instfreq(sig);%计算瞬时频率----希尔伯特变换
subplot(211),plot(t,ifr);axis tight
fnorm=0:.05:.5;
gd=sgrpdlay(sig,fnorm);%计算群延时
subplot(212),plot(gd,fnorm);axis tight
%只有当T*B很大时群延时才会和瞬时频率相同
t=2:255;
sig1=amgauss(256,128,90).*fmlin(256,0,0.5);
[~,T1]=loctime(sig1); [~,B1]=locfreq(sig1);
T1*B1 %---> T1*B1=15.9138
ifr1=instfreq(sig1,t); f1=linspace(0,0.5-1/256,256);
gd1=sgrpdlay(sig1,f1);
subplot(211),plot(t,ifr1,'*',gd1,f1,'-');axis tight
sig2=amgauss(256,128,30).*fmlin(256,0.2,0.4);
[tm,T2]=loctime(sig2); [fm,B2]=locfreq(sig2);
T2*B2 %---> T2*B2=1.224
ifr2=instfreq(sig2,t); f2=linspace(0.2,0.4,256);
gd2=sgrpdlay(sig2,f2); 
subplot(212),plot(t,ifr2,'*',gd2,f2,'-');axis tight

%% 6、非平稳信号的产生
clear,clc,close all;
fm1=fmlin(256,0,0.5);%LFM信号
am1=amgauss(256,200);%指定高斯窗的中心点200
sig1=am1.*fm1;
subplot(311),plot(real(sig1));axis tight
fm2=fmconst(256,0.2);%单频信号
am2=amexpo1s(256,100);%指定指数衰减窗的起始点为100
sig2=am2.*fm2; 
subplot(312),plot(real(sig2));axis tight
[fm3,am3]=doppler(256,200,4000/60,10,50);%多普勒信号--非matlab自带函数
% 采样频率200Hz，目标频率为4000/60Hz，观察者和目标举例10m，目标以50m/s的速度靠近
sig3=am3.*fm3; 
subplot(313),plot(real(sig3));axis tight
noise=noisecg(256,.8);%有色噪声----AWGN经过滤波器后的结果
sign=sigmerge(sig1,noise,-10); %信号叠加
subplot(311),hold on; plot(real(sign),'r');


%% 7、非平稳信号的叠加----多组分非平稳信号
clear,clc,close all;
N=128; 
x1=fmlin(N,0.5,0.3); x2=fmlin(N,0.1,0.5);
x=x1+x2;%信号叠加
ifr=instfreq(x); %瞬时频率
subplot(211); plot(ifr);axis tight;
fn=0:0.01:0.5; 
gd=sgrpdlay(x,fn);%群延时
subplot(212); plot(fn,gd);axis tight;
TF = tfrstft(x);%短时傅立叶变换，
% tfrstft(x);单独使用时可以增加绘制功率谱等数据
figure,imagesc(abs(TF));axis xy





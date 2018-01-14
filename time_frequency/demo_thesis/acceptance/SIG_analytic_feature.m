%% 解析信号的频谱性质示例
clear all; close all; clc; 
Fs = 100;N=128; %单位对应MHz, us
t = (0:(N-1))/Fs; f = linspace(-Fs/2,Fs/2,N);
s = real(fmconst(N,0.07,1) + fmconst(N,0.22,1));%7M+22M COS信号叠加
sF = abs(fftshift(fft(s)));sF = sF/max(sF);
sa = hilbert(s);%解析信号
saF = abs(fftshift(fft(sa)));saF = saF/max(saF);
%绘制正弦信号及其频谱
figure;plot(t,s,'k-'); xlabel('时间/\mus');ylabel('幅度/V');
% set_gca_style([7,4]);
figure;plot(f,sF,'k-'); xlabel('频率/MHz');ylabel('归一化幅度');
% set_gca_style([7,4]);
%绘制解析信号及其频谱
figure;plot(t,real(sa),'b^-','LineWidth',1.3,'MarkerSize',3);hold on; 
plot(t,imag(sa),'k-.','LineWidth',0.7); xlabel('时间/\mus');ylabel('幅度/V');legend('实部','虚部');
% set_gca_style([7,4]);
figure;plot(f,saF,'k-'); xlabel('频率/MHz');ylabel('归一化幅度');
% set_gca_style([7,4]);

%% SFM信号的SFMT变换
clear all; clc; close all;
N = 128; k0 = 2;l0 = 16;%信号参数
t = [0:N-1]';
s = exp(1i*l0/k0*sin(2*pi*k0*t/N));%plot(t,real(s),'.-') %公式5，已知k0和l0时恢复原始信号的方法
[X,s_hat] = sfmt(s);
surf(abs(X));xlabel('k');ylabel('l');axis tight; grid on;
colormap('hot');%shading interp

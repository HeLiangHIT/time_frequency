% CS理论去掉压缩采样，只考虑重构的算法，那么对于均匀满足采样定理的信号，如何重构的问题需要考虑一下。

clc;clear all; close all;

%%  1. 时域测试信号生成
clear all; close all; clc;
N=512;%采样点数
t=1:N;
f=linspace(0,0.5,N);
T0 = N/2;%其实参考相位位置
[sig1,if1] = fmlin(N,0,0.3,T0);
[sig2,if2] = fmlin(N,0.2,0.5,T0);
k=0.3/N;%LFM斜率
p = mod(2/pi*acot(-k*N),2);% FRFT阶数，归一到0-2之间
x_org = sig1+sig2;
% x=awgn(x_org,10,'measured');%添加噪声
x = x_org;

%%  3.  正交匹配追踪法重构信号(本质上是L_1范数最优化问题)
% 正交基构造
bais=eye(N,N);
Psi = zeros(size(bais));
for k = 1:N
    Psi(:,k) = frft(bais(:,k),p)*sqrt(N);%对各列基作FRFT变换
end
% imagesc(real(Psi));imagesc(imag(Psi));imagesc(abs(Psi));
% frft_s = frft(s,p);%计算 FRFT可以看出只有两个信号分量

% OMP重构
T=Psi';           %  恢复矩阵(测量矩阵*正交反变换矩阵)，y=恢复矩阵*s。其中y为观测数据，s为稀疏表示系数
[hat_y1,r_n] = omp(x,T,N,1);%OMP算法重构1个分量
hat_s1=Psi'*hat_y1.';                         %  做逆傅里叶变换重构得到时域信号

[hat_y2,r_n] = omp(r_n,T,N,1);%OMP算法重构1个分量
hat_s2=Psi'*hat_y2.';                         %  做逆傅里叶变换重构得到时域信号

%%  4.  恢复信号和原始信号对比
figure
plot(t,real(sig1),'.-b');hold on              %  原始信号
plot(t,real(hat_s1),'o-r')                 %  重建信号
legend('原始信号','重建信号'),axis tight; xlabel('t/s')
%误差分析
fprintf('分量1重构MSE = %8f\n',norm(hat_s1 - sig1, 'fro')/norm(x - sig1,'fro'))

figure
plot(t,real(sig2),'.-b');hold on              %  原始信号
plot(t,real(hat_s2),'o-r')                 %  重建信号
legend('原始信号','重建信号'),axis tight; xlabel('t/s')
%误差分析
fprintf('分量2重构RMSE = %8f\n',norm(hat_s2 - sig2, 'fro')/norm(x - sig2,'fro'))

figure
plot(f,abs(frft(x_org,p)),'b.-'),axis tight;hold on
plot(f,abs((hat_y1+hat_y2)*sqrt(N)),'o-r')
legend('原始信号FRFT谱','OMP算法非零基');









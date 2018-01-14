% CS理论去掉压缩采样，只考虑重构的算法，那么对于均匀满足采样定理的信号，如何重构的问题需要考虑一下。

clc;clear all; close all;

%%  1. 时域测试信号生成
N=512;    %  信号长度（采样数量），假设观测数和信号长度相同
fs=1600;   %  采样频率
f = [50; 150; 200];%信号频点，当采样
p = [0,pi/4,0];%信号相位
A = [0.5,0.6,0.3];%信号幅度
K = 2*length(f);%FFT基对应的信号稀疏度为2*信号个数
[t,x_org]=cosSignalGen(f,p,A,fs,N);%信号产生
x=awgn(x_org,10,'measured');%添加噪声

%%  2.  时域信号压缩传感
Phi=eye(N);             %  测量矩阵，满足采样定理时就是单位矩阵
s=Phi*x.';                 %  获得线性测量 ，s相当于文中的y矩阵

%%  3.  正交匹配追踪法重构信号(本质上是L_1范数最优化问题)
%匹配追踪：找到一个其标记看上去与收集到的数据相关的小波；在数据中去除这个标记的所有印迹；不断重复直到我们能用小波标记“解释”收集到的所有数据。
Psi=fft(eye(N,N))/sqrt(N);    %  傅里叶正变换矩阵，作为信号的稀疏表示基向量组合
% 其实这个Psi各行（或列）分别对应的就是各个频率点为1的时域信号，也就是具有
% 各个频率点的时域信号信息，相位信息对此并无影响，因为在 OMP运算中会保留相位信息储存到hat_y中

T=Phi*Psi';                          %  恢复矩阵(测量矩阵*正交反变换矩阵)，y=恢复矩阵*s。其中y为观测数据，s为稀疏表示系数

hat_y = omp(s,T,N,K);               %OMP算法重构
hat_x=real(Psi'*hat_y.').';                         %  做逆傅里叶变换重构得到时域信号


%%  4.  恢复信号和原始信号对比
subplot(211); hold on;
plot(t,x_org,'o-r')              %  原始信号
plot(t,x,'b.-')                      %带噪声信号
plot(t,hat_x,'kp-')                 %  重建信号
legend('Original','Nosied','Recovery'),axis tight

subplot(212); hold on;
plot(abs(hat_y*sqrt(N)),'o-k'),
plot(abs(fft(x_org)),'r.-'),axis tight
legend('s','fft(x)');

SnrNoise = norm(x_org, 'fro')/norm(x - x_org, 'fro');   %  信噪比
SnrRec = norm(x_org, 'fro')/norm(hat_x - x_org, 'fro');   %  重构方差

fprintf('MSE = %8f\n',norm(hat_x - x_org, 'fro'))



%% 论文第二章示意图：
% 注：图像保存尺寸常用（字号都选择10.5pt）
% MATLAB设置尺寸->WORD修正尺寸
% 6*4->6*4
% 6*6->5*5
% 8*6->5*6.67

%% LFM信号的时域和频域波形显示：图2-2
clear,clc,close all;
N=512;%采样点数
fs = 200e6;%100M
FNORMI = 0.1e6/fs;%起始频率->相对于采样频率，between -0.5 and 0.5
FNORMF = 100e6/fs;%结束频率->相对于采样频率，between -0.5 and 0.5
t = (1:N)/fs;
T0 = N/2;%time reference for the phase,相位的参考时间？
[Y,IFLAW]=fmlin(N,FNORMI,FNORMF,T0);
figure('Name','LFM信号的时域'),plot(t,real(Y));axis tight;%CHIRP信号
xlabel('t/s');
Y_W=abs(fftshift(abs(fft(Y)).^2));%
Y_W = Y_W/max(Y_W);
f = linspace(-0.5*fs,0.5*fs,N);
figure('Name','LFM信号的频域'),plot(f,abs(Y_W));axis tight;%频谱
xlabel('f/Hz');%归一化频率
pause


%% LFM信号的FRFT变换：图2-4
clear,clc,close all;
N=512;%采样点数
N=128;      %采样点数
r=0.05;     %分数域采样间隔，实际仿真时越小越精确
fs =1;  %采样频率
f0 = 0;  fend = 0.5;
s = fmlin(N,f0,fend,1);
t = 1:N;
f = linspace(-0.5,0.5,N);%频率点【必须是正负连续的，fmlin直接返回的f不正确】
% 不同阶数下的FRFT变换
a=0:r:2;    %FRFT阶数，参考论文2.1
G=zeros(length(a),length(s));	%不同阶数的变换结果保存
f_opt=0;        %记录最大频点
for l=1:length(a)
    T=frft(s,a(l));         %分数阶傅立叶变换
    G(l,:)=abs(T(:));       %取变换后的幅度
  if(f_opt<=max(abs(T(:))))     
    [f_opt,f_ind]=max(abs(T(:)));       %当前最大点在当前域的横坐标点
    a_opt=a(l);                %当前最大值点的阶数a
  end
end
%绘制三维图形
[xt,yf]=meshgrid(a,f);             %获取坐标轴坐标
surf(xt',yf',G);               % colormap('Autumn');     %颜色模式
xlabel('p');ylabel('u');%u为在p阶数下的等效频域
axis tight; grid on;
%计算调频斜率
nor_coef=(t(N)-t(1))/fs;      %根据采样率计算归一化因子，注意论文上的斜率是以数字频率为单位的，因此公式不完全一样
kr=-cot(a_opt*pi/2)/nor_coef;   %k参数的估计值，其中alpha=pi*a/2
%计算起始频率
u0=f(f_ind);      %最大点对应的等效频率
f_center=u0*csc(a_opt*pi/2);  % 中心频率f0的估计值
fprintf('产生：调频斜率=%f， 中心频率为=%f \n',(fend-f0)/N,(f0+fend)/2);
fprintf('估计：调频斜率=%f， 中心频率为=%f \n',kr,f_center);
pause


%% SFM信号的时域和频域波形显示：图2-6
clear,clc,close all;
N=512;%采样点数
fs = 200e6;%100M
t = (1:N)/fs;
FNORMI = 0.1e6/fs;%最小频率
FNORMAX = 100e6/fs;%最大频率
[Y,IFLAW]=fmsin(N,FNORMI,FNORMAX);
figure('Name','SFM信号的时域'),plot(t,real(Y));axis tight;%CHIRP信号
xlabel('t/s');
Y_W=abs(fftshift(abs(fft(Y)).^2));%
Y_W = Y_W/max(Y_W);
f = linspace(-0.5*fs,0.5*fs,N);
figure('Name','LFM信号的频域'),plot(f,abs(Y_W));axis tight;%频谱
xlabel('f/Hz');%归一化频率
pause



%% SFM信号的SFMT变换：还未实现加入



%% TFR获取的对比：图2-7
clear all; close all; clc;
N=512;%采样点数
t=1:N;
f=linspace(0,0.5,N);
[sig,IF]=fmlin(N,0,0.5);
figure,tfr_sp = tfrsp(sig); imagesc(t,f,tfr_sp(1:N/2,:));axis xy; xlabel('t/s'); ylabel('w');colormap('hot')
figure,tfr_wv = tfrwv(sig); tfr_wv(tfr_wv<0)=0;
imagesc(t,f,tfr_wv);axis xy; xlabel('t/s'); ylabel('w');colormap('hot')
figure,tfr_spwv = tfrspwv(sig); tfr_spwv(tfr_spwv<0)=0;
imagesc(t,f,tfr_spwv);axis xy; xlabel('t/s'); ylabel('w');colormap('hot')
pause


%% TFR获取的对比：图2-8和2-10部分
clear all; close all; clc;
N=512;%采样点数
t=1:N;
f=linspace(0,0.5,N);
sig=fmlin(N,0,0.3)+fmlin(N,0.2,0.5);
figure,tfr_sp = tfrsp(sig); imagesc(t,f,tfr_sp(1:N/2,:));axis xy; xlabel('t/s'); ylabel('w');colormap('hot')
figure,tfr_wv = tfrwv(sig); tfr_wv=abs(tfr_wv);
imagesc(t,f,tfr_wv);axis xy; xlabel('t/s'); ylabel('w');colormap('hot')
[tfr_spwv,tfr_rspwv] = tfrrspwv(sig); tfr_rspwv = abs(tfr_rspwv); tfr_spwv = abs(tfr_spwv);
figure,imagesc(t,f,tfr_spwv);axis xy; xlabel('t/s'); ylabel('w');colormap('hot')
figure,imagesc(t,f,tfr_rspwv);axis xy; xlabel('t/s'); ylabel('w');colormap('hot')

%% TFR获取的对比：图2-9和2-10部分
sig=fmlin(N,0,0.25)+fmsin(N,0.25,0.45);
figure,tfr_sp = tfrsp(sig); imagesc(t,f,tfr_sp(1:N/2,:));axis xy; xlabel('t/s'); ylabel('w');colormap('hot')
figure,tfr_wv = tfrwv(sig); tfr_wv=abs(tfr_wv);
imagesc(t,f,tfr_wv);axis xy; xlabel('t/s'); ylabel('w');colormap('hot')
[tfr_spwv,tfr_rspwv] = tfrrspwv(sig); tfr_rspwv = abs(tfr_rspwv); tfr_spwv = abs(tfr_spwv);
figure,imagesc(t,f,tfr_spwv);axis xy; xlabel('t/s'); ylabel('w');colormap('hot')
figure,imagesc(t,f,tfr_rspwv);axis xy; xlabel('t/s'); ylabel('w');colormap('hot')
pause



%% RSPWVD的图像处理：TFR二值化+霍夫检测+信号恢复：图2-11到13
clear all; close all; clc;
N=512;%采样点数
t=1:N;  f=linspace(0,0.5,N);
T0 = 1;%其实参考相位位置
[sig1,if1] = fmlin(N,0,0.3,T0);
[sig2,if2] = fmlin(N,0.2,0.5,T0);
sig = sig1+sig2;
[~,tfr] = tfrrspwv(sig); tfr = abs(tfr);%获取理想的TFR
% 二值化
tfr_nor = tfr/max(tfr(:));%归一化TFR
hresh = graythresh(tfr_nor);%自适应选择阈值
tfr_bin = tfr_nor>hresh;%二值化
imshow(tfr_bin); axis xy;hold on
% 霍夫变换直线检测
[H,T,R] = hough(tfr_bin);%霍夫变换，查看帮助目录会有更多收获
P  = houghpeaks(H,10,'threshold',ceil(0.3*max(H(:))));%最多检测10个峰值，峰值的阈值必须高于0.3maxH
lines = houghlines(tfr_bin,T,R,P);%检测直线，包含线段端点
%信号恢复
IFLAW = cell(1,length(lines));
sig_each = cell(1,length(lines));
for k = 1:length(lines)
    x1 = lines(k).point1;x1(2) = x1(2)*0.5/N;%归一化到采样频率下
    x2 = lines(k).point2;x2(2) = x2(2)*0.5/N;%归一化到采样频率下
    xy = [lines(k).point1; lines(k).point2];    plot(xy(:,1),xy(:,2),'g');%绘图
    IFLAW{k} = (t-x1(1))*(x2(2) - x1(2))/(x2(1)-x1(1))+x1(2);%各个信号分量的瞬时频率函数
    if_temp = IFLAW{k};%分量的IF特征
    if_temp(if_temp>0.5) = 0.5;%防止采样定理冲突
    sig_each{k} = fmodany(if_temp',T0);%产生信号
end
%恢复信号对比：时域
figure; plot(t,real(sig1),'b-',t,real(sig_each{1}),'r.');legend('原始信号','反演信号');axis tight;xlabel('t/s');
figure; plot(t,real(sig2),'b-',t,real(sig_each{2}),'r.');legend('原始信号','反演信号');axis tight;xlabel('t/s');
figure;plot(t,real(sig),'k.-'); axis tight; xlabel('t/s');
%恢复信号对比：IF
figure;
h1=axes('position',[0.1 0.08 0.88 0.88]); box on; 
h2=axes('position',[0.15 0.6 0.4 0.32]); box on;
plot(h1,t,if1,'b.-',t,IFLAW{1},'o-r'); legend(h1,'原始信号','反演信号'); axis tight;
plot(h2,t(1:10),if1(1:10),'b.-',t(1:10),IFLAW{1}(1:10),'o-r');axis tight;xlabel(h1,'t/s');ylabel(h1,'f/Hz');
pause


%% 信号的稀疏分解重构：OMP算法的FRFT稀疏基重构
clc;clear all; close all;
N=512;%采样点数
t=1:N;
f=linspace(0,0.5,N);
T0 = N/2;%其实参考相位位置
[sig1,if1] = fmlin(N,0,0.3,T0);
[sig2,if2] = fmlin(N,0.2,0.5,T0);
k=0.3/N;%LFM斜率
p = mod(2/pi*acot(-k*N),2);% FRFT阶数，归一到0-2之间
x = sig1+sig2;

% 正交基构造
bais=eye(N,N);
Psi = zeros(size(bais));
for k = 1:N
    Psi(:,k) = frft(bais(:,k),p)*sqrt(N);%对各列基作FRFT变换
end

% OMP重构
T=Psi';           %  恢复矩阵(测量矩阵*正交反变换矩阵)，y=恢复矩阵*s。其中y为观测数据，s为稀疏表示系数
[hat_y1,r_n] = omp(x,T,N,1);%OMP算法重构第1个分量
hat_s1=Psi'*hat_y1.';                         %  做逆傅里叶变换重构得到时域信号
[hat_y2,r_n] = omp(r_n,T,N,1);%OMP算法重构第2个分量
hat_s2=Psi'*hat_y2.';                         %  做逆傅里叶变换重构得到时域信号

% 重构信号和原始信号对比
figure('Name','第一个分量');
plot(t,real(sig1),'.-b');hold on              %  原始信号
plot(t,real(hat_s1),'o-r')                 %  重建信号
legend('原始信号','重构信号'),axis tight;xlabel('t/s');

figure('Name','第二个分量');
plot(t,real(sig2),'.-b');hold on              %  原始信号
plot(t,real(hat_s2),'o-r')                 %  重建信号
legend('原始信号','重构信号'),axis tight;xlabel('t/s');
%误差分析
fprintf('分量1重构MSE = %8f\n',norm(hat_s1 - sig1, 'fro'))
fprintf('分量2重构MSE = %8f\n',norm(hat_s2 - sig2, 'fro'))

figure('Name','FRFT和OMP基对比')
plot(f,abs(frft(x,p)),'b.-'),axis tight;hold on
plot(f,abs((hat_y1+hat_y2)*sqrt(N)),'o-r');xlabel('w');
legend('原始信号FRFT谱','OMP算法非零原子');
pause













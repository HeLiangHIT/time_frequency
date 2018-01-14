%% TFR域图像IF特征获取域图像恢复


%% 测试信号恢复
% TFR获取
clear all; close all; clc;
N=512;%采样点数
t=1:N;
f=linspace(0,0.5,N);
T0 = 1;%其实参考相位位置
[sig1,if1] = fmlin(N,0,0.3,T0);
[sig2,if2] = fmlin(N,0.2,0.5,T0);
sig = sig1+sig2;
[~,tfr] = tfrrspwv(sig); tfr = abs(tfr);%获取理想的TFR
% 二值化
% hist_tfr=hist(tfr(:),linspace(min(tfr(:)),max(tfr(:)),100));%从直方图分布中获取最佳阈值或许是一个不错的选择呢
tfr_nor = tfr/max(tfr(:));%归一化TFR
hresh = graythresh(tfr_nor);%自适应选择阈值
tfr_bin = tfr_nor>hresh;%二值化
imshow(tfr_bin); axis xy;hold on
% % 细化操作
% tfr_thin = bwmorph(tfr_bin, 'thin',Inf);%细化操作
% subplot(122);imshow(tfr_thin); axis xy;%看起来细化操作并没有产生帮助
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
    xy = [lines(k).point1; lines(k).point2];    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');%绘图
    IFLAW{k} = (t-x1(1))*(x2(2) - x1(2))/(x2(1)-x1(1))+x1(2);%各个信号分量的瞬时频率函数
    if_temp = IFLAW{k};%分量的IF特征
    if_temp(if_temp>0.5) = 0.5;%防止采样定理冲突
    sig_each{k} = fmodany(if_temp',T0);%产生信号
end
%恢复信号对比：时域
figure; plot(t,real(sig1),'b.-',t,real(sig_each{1}),'ro-');legend('原始信号','反演信号');axis tight; xlabel('t/s')
figure; plot(t,real(sig2),'b.-',t,real(sig_each{2}),'ro-');legend('原始信号','反演信号');axis tight; xlabel('t/s')
figure; subplot(121); plot(t,if1,'b.-',t,IFLAW{1},'o-r'); legend('原始信号','反演信号');axis tight
subplot(122);plot(t,if2,'b.-',t,IFLAW{2},'o-r'); legend('原始信号','反演信号');axis tight
%误差来源：TFR端点处的噪声影响了直线检测，让直线斜率有点偏差导致了这么大误差的产生。
% 解决方法：去除两端的图像内容后再检测，或者对于各个t的F做均值等操作来更好的估计确切F值。



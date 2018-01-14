%% LFM在FRFT域的最佳估计展示
clear,clc,close all;
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
    T=frft_org(s,a(l));         %分数阶傅立叶变换
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
fprintf('产生：调频斜率=%f， 中心频率为=%f \n',(fend-f0)/N*fs,(f0+fend)/2);
fprintf('估计：调频斜率=%f， 中心频率为=%f \n',kr,f_center);
% tfsapl(s,G,'GrayScale','on','xlabel','p','ylabel','u');%效果也不好
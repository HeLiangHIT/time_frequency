%% 原理介绍相关图像产生




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
Gt = G/max(G(:));
[xt,yf]=meshgrid(a,f);             %获取坐标轴坐标
surf(xt',yf',10*log10(1+Gt));               
colormap('Autumn');     %颜色模式
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
% set_gca_style([8,6]); box off; colormap('hot');


%% 无交叉LFM+SFM信号的时变滤波
clear all; clc; close all
Fs = 100;N=256; 
t = (0:(N-1))/Fs; f = linspace(-Fs/2,Fs/2,N);
[s1, sif1] = fmlin(N,0.1,0.2,120);
[s2, sif2] = fmsin(N,0.25,0.45,N+50);
s_org = s1+s2;%信号叠加
s = awgn(s_org,0,'measured');%加5dB噪声【SNR很高时分离的信号几乎完美重合】

%%%%%%%  STFT TVF
% [sh1,tfr,tfrv1] = stftSeparation(s,[sif1,sif2],20);%固定窗长度的时变滤波
[sh2,tfr,tfrv2] = stftSeparationAdv(s,[sif1,sif2],20);%自适应窗长度的时变滤波
figure('Name','STFT');imagesc(abs(tfr)); set_gca_style([4,4],'img');
figure('Name','STFT-ada-window-sig1');imagesc(abs(tfrv2(:,:,1))); set_gca_style([4,4],'img');
figure('Name','STFT-ada-window-sig2');imagesc(abs(tfrv2(:,:,2))); set_gca_style([4,4],'img');

figure('Name','sigmix-time');plot(t,real(s),'k-'); 
% h = legend('${s_1(t)+s_2(t)}$','${s(t)}$'); set(h,'Interpreter','latex')
xlabel('t/\mus'),ylabel('A/V');set_gca_style([16,4]);%xlim([t(1),t(128)]);%axis([t(1),t(128),-2.2,7])%查看边缘值
figure('Name','sig1-time');plot(t,real(s1),'k-',t,real(sh2(:,1)),'b--'); 
% h=legend('$s_1(t)$','$ \tilde s_1(t)$');set(h,'Interpreter','latex')
xlabel('t/\mus'),ylabel('A/V');set_gca_style([8,4]);%xlim([t(1),t(end)])%查看边缘值
figure('Name','sig2-time');plot(t,real(s2),'k-',t,real(sh2(:,2)),'b--'); 
% h=legend('$s_2(t)$','$ \tilde s_2(t)$');set(h,'Interpreter','latex')
xlabel('t/\mus'),ylabel('A/V');set_gca_style([8,4]);%xlim([t(1),t(enf)])%查看边缘值


%%%%%%% STFRFT TVF
% [sh1,tfr,tfrv1] = stfrftSeparation(s,[sif1,sif2],8);%自适应窗长度的时变滤波
[sh2,tfr,tfrv2] = stfrftSeparationAdv(s,[sif1,sif2],8);%自适应窗长度的时变滤波--FRFT能量更集中，因此需要的宽度更小
figure('Name','STFRFT-sig1');imagesc(abs(tfr(:,:,1))); set_gca_style([4,4],'img');
figure('Name','STFRFT-sig2');imagesc(abs(tfr(:,:,2))); set_gca_style([4,4],'img');
figure('Name','STFRFT-ada-window-sig1');imagesc(abs(tfrv2(:,:,1))); set_gca_style([4,4],'img');
figure('Name','STFRFT-ada-window-sig2');imagesc(abs(tfrv2(:,:,2))); set_gca_style([4,4],'img');

figure('Name','sig1-time');plot(t,real(s1),'k-',t,real(sh2(:,1)),'b--'); 
xlabel('t/\mus'),ylabel('A/V');set_gca_style([8,4]);grid off;
figure('Name','sig2-time');plot(t,real(s2),'k-',t,real(sh2(:,2)),'b--'); 
xlabel('t/\mus'),ylabel('A/V');set_gca_style([8,4]);grid off;










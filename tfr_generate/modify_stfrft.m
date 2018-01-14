%% 辅助校正STFRFT函数的正确性

%% 1、LFM信号的FRFT谱峰值和原始信号的中心频率关系
clear all; clc, close all;
N=128;  t = 1:N;    %采样点数
fs =1;  f0 = -0.5;  fend = 0.5;%采样频率
[s_org,iflaw] = fmlin(N,f0,fend,1);
% [s_org,iflaw] = fmsin(N,f0,fend,N);
s = awgn(s_org,5,'measured');
% 计算分数阶的最佳角度
kgen = diff(iflaw);kgen = [kgen(1);kgen];% IF的导数是斜率k
popt = -acot(kgen*N)*2/pi; %各个点的最佳FRFT阶数
% p = mod(popt,4); p(p>2) = p(p>2)-2; 
% p(p>1.5) = p(p>1.5)-1; p(p<0.5) = p(p<0.5)+1; 
% plot(p)

% % 计算最佳旋转阶数
% pSel = 0:0.01:2;
% G=zeros(length(pSel),length(s));	%不同阶数的变换结果保存
% maxAm=0;        %记录最大频点
% for k=1:length(pSel)
%     tmp=fracft(s,pSel(k));      %分数阶傅立叶变换
%     G(k,:)=abs(tmp(:));       %取变换后的幅度
%     if(maxAm<=max(abs(tmp(:))))
%         [maxAm,uOpt]=max(abs(tmp(:)));       %当前最大点在当前域的横坐标点
%         pOpt=pSel(k);                %当前最大值点的阶数a
%     end
% end
% imagesc(1:length(s),pSel,G);xlabel('ut');ylabel('angle');axis xy;

% 测试STLOFRFT的正确性
[TFD_LOSTFRFT, ang] = tfrLoStfrft(s,0.02);%计算复杂度很高
TFD_STFT = tfrsp(s);
subplot(1,3,1);plot(ang,'.-');axis tight;ylim([0,2]);title('angle');
subplot(1,3,2);imagesc(abs(TFD_LOSTFRFT));axis xy;title('LOSTFRFT');
subplot(1,3,3);imagesc(abs(TFD_STFT));axis xy;title('STFT');

%% 测试SFM信号
clear all;clc;close all;
N=256;
s_org = 2*fmsin(N,-0.1,0.2,N) + 1*fmlin(N,0.3,0.4);
s = awgn(s_org,2,'measured');
[TFD_LOSTFRFT, ang] = tfrLoStfrft(s,0.05);%计算复杂度很高
% [TFD_COSTFRFT, ang] = tfrCoStfrft(s,0.01);%计算复杂度很高
TFD_STFT = tfrsp(s);
subplot(1,3,1);plot(ang,'.-');axis tight;ylim([0,2]); title('angle');
subplot(1,3,2);imagesc(abs(TFD_LOSTFRFT));axis xy;title('LOSTFRFT');
subplot(1,3,3);imagesc(abs(TFD_STFT));axis xy;title('STFT');








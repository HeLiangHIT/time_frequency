%% 测试信号合成方法：WVD 或者 STFT下的时变滤波
% 测试发现STFT下的时变滤波比较靠谱，但是对于交叉出依然处理不正确。
% 实际论文中需要使用蒙特卡洛方法演示对比哪种方法更好！这里只是原理性的验证。


%% 使用synthesize+WVD方法合成信号--不可行，主要是相位偏离了，单分量时可以使用带噪声的信号修正相位畸变，多分量时不可以。
% clear all; close all;clc
% s = fmlin(512,0,0.5,15);
% tfd_wvd = quadtfd( s, 127, 1, 'wvd', 512 );
% s_hat = synthesize( tfd_wvd, 'wvd', 127, s);
% % pf = sum(s.*conj(s_hat)); 
% % s_hat = s_hat.* pf/abs(pf); % 相位畸变校正公式
% plot(1:length(s),imag(s),'b.-',1:length(s_hat),imag(s_hat),'rx-'); axis tight

%% 1.STFT下的时变滤波操作：自适应窗长度和固定窗长度的对比
clear all; clc; close all
N=512; t = 1:N;
[s_org,sif] = fmlin(N,0,0.5,120);
s = awgn(s_org,10,'measured');
[sh1,tfr,tfrv1] = stftSeparation(s,sif,30);%固定窗长度的时变滤波
[sh2,tfr,tfrv2] = stftSeparationAdv(s,sif,30);%自适应窗长度的时变滤波
figure;plot(t,real(s_org),'b.-',t,real(s),'g',t,real(sh1),'r.-',t,real(sh2),'k.-'); 
axis tight;legend('orignal','noised','windowed','adaptive');%xlim([1,128])%查看边缘值
figure;subplot(131);imagesc(abs(tfr)); axis xy; 
subplot(132);imagesc(abs(tfrv1)); axis xy; 
subplot(133);imagesc(abs(tfrv2)); axis xy; 

pause
%% 2.STFT下单分量AM-FM-PM信号的恢复
clear all; clc; close all
N=512;  t = 1:N;
[sfm, sif] = fmlin(N,0,0.5,50);%plot(real(sfm))
sam = (cos(0.05*t)+2)/3;%plot(sam)
s_org = sfm.*sam.';%plot(real(s)) % 幅度调制
s = awgn(s_org,5,'measured');%加5dB噪声
[sh1,tfr,tfrv1] = stftSeparation(s,sif,20);%固定窗长度的时变滤波
[sh2,tfr,tfrv2] = stftSeparationAdv(s,sif,20);%自适应窗长度的时变滤波
figure;plot(t,real(s_org),'b.-',t,real(s),'g',t,real(sh1),'r.-',t,real(sh2),'k.-'); 
axis tight;legend('orignal','noised','windowed','adaptive');%xlim([1,128])%查看边缘值
figure;subplot(131);imagesc(abs(tfr)); axis xy; 
subplot(132);imagesc(abs(tfrv1)); axis xy; 
subplot(133);imagesc(abs(tfrv2)); axis xy; 

pause
%% STFT下2分量信号分离+幅度校正
clear all; clc; close all
N=512;  t = 1:N;
[s1, sif1] = fmlin(N,0,0.4,120);
[s2, sif2] = fmlin(N,0.5,0,360);
s_org = s1+s2;%信号叠加
s = awgn(s_org,10,'measured');%加5dB噪声
[sh1,tfr,tfrv1] = stftSeparation(s,[sif1,sif2],20);%固定窗长度的时变滤波
[sh2,tfr,tfrv2] = stftSeparationAdv(s,[sif1,sif2],20);%自适应窗长度的时变滤波
% 绘图对比
figure;
subplot(211);plot(t,real(s1),'b.-',t,real(s),'g',t,real(sh1(:,1)),'r.-',t,real(sh2(:,1)),'k.-'); 
axis tight;legend('orignal','noised intersect','windowed','adaptive');%xlim([1,128])%查看边缘值
subplot(212);plot(t,real(s2),'b.-',t,real(s),'g',t,real(sh1(:,2)),'r.-',t,real(sh2(:,2)),'k.-'); 
axis tight;legend('orignal','noised intersect','windowed','adaptive');%xlim([1,128])%查看边缘值
figure;
subplot(131);imagesc(abs(tfr)); axis xy; 
subplot(232);imagesc(abs(tfrv1(:,:,1))); axis xy; %固定窗
subplot(233);imagesc(abs(tfrv1(:,:,2))); axis xy; 
subplot(235);imagesc(abs(tfrv2(:,:,1))); axis xy; %自适应窗
subplot(236);imagesc(abs(tfrv2(:,:,2))); axis xy; 
%　获取交叉处的时频位置
figure; overlayedTfr = sum(tfrv2,3) - tfr.*(sum(tfrv2,3)~=0); 
imagesc(abs(overlayedTfr));axis xy;

pause
%% STFT下3分量信号分离+幅度校正
clear all; clc; close all
N=512;  t = 1:N;
[s1, sif1] = fmlin(N,0,0.4,120);
[s2, sif2] = fmlin(N,0.4,0,360);
[s3, sif3] = fmlin(N,0.2,0.2,60);
s_org = s1+s2+s3;%信号叠加
s = awgn(s_org,10,'measured');%加5dB噪声
[sh1,tfr,tfrv1] = stftSeparation(s,[sif1,sif2,sif3],20);%固定窗长度的时变滤波
[sh2,tfr,tfrv2] = stftSeparationAdv(s,[sif1,sif2,sif3],20);%自适应窗长度的时变滤波
figure;
subplot(311);plot(t,real(s1),'b.-',t,real(s),'g',t,real(sh1(:,1)),'r.-',t,real(sh2(:,1)),'k.-'); 
axis tight;legend('orignal','noised intersect','windowed','adaptive');%xlim([1,128])%查看边缘值
subplot(312);plot(t,real(s2),'b.-',t,real(s),'g',t,real(sh1(:,2)),'r.-',t,real(sh2(:,2)),'k.-'); 
axis tight;legend('orignal','noised intersect','windowed','adaptive');%xlim([1,128])%查看边缘值
subplot(313);plot(t,real(s3),'b.-',t,real(s),'g',t,real(sh1(:,3)),'r.-',t,real(sh2(:,3)),'k.-'); 
axis tight;legend('orignal','noised intersect','windowed','adaptive');%xlim([1,128])%查看边缘值
figure;
subplot(141);imagesc(abs(tfr)); axis xy; 
subplot(242);imagesc(abs(tfrv1(:,:,1))); axis xy; 
subplot(243);imagesc(abs(tfrv1(:,:,2))); axis xy; 
subplot(244);imagesc(abs(tfrv1(:,:,3))); axis xy; 
subplot(246);imagesc(abs(tfrv2(:,:,1))); axis xy; 
subplot(247);imagesc(abs(tfrv2(:,:,2))); axis xy; 
subplot(248);imagesc(abs(tfrv2(:,:,3))); axis xy; 
%　获取交叉处的时频位置
figure; oTfr = sum(tfrv2,3) - tfr.*(sum(abs(tfrv2),3)~=0); 
imagesc(abs(oTfr));axis xy;
%  获取分量1被叠加的部分--方法1
figure; 
[r,c] = find(oTfr~=0);%找到交叉分量不为0的地方
oTfr1 = zeros(size(tfr));oTfr1(r,c) = tfrv2(r,c,1);%取分量1存在于交叉分量的地方的值
imagesc(abs(oTfr1));axis xy;
%  获取分量1被叠加的部分--方法2
figure; 
oTT = sum(tfrv2,3);Tfr1 = zeros(size(tfr));
Tfr1(tfrv2(:,:,1)~=0) = oTT(tfrv2(:,:,1)~=0);%可以得到分量1在各个位置实际计算的频率范围
oTfr1 = Tfr1 - tfrv2(:,:,1); % 减去当前分量计算的幅度值即可得到其赠加部分的幅度值
% Tfr1r = Tfr1 - oTfr1; %获得实际的幅度值！？其实就是恢复到tfrv2(:,:,1)了。
imagesc(abs(oTfr1));axis xy;









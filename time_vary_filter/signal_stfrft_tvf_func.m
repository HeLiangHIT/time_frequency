%% 测试STFRFT下的时变滤波操作，主要对比STFT下的结论。


%% 1.STFRFT下的时变滤波操作：自适应窗长度和固定窗长度的对比，对比其和STFT滤波的优化性能
clear all; clc; close all
N=256; t = 1:N;
[s_org,sif] = fmlin(N,0,0.3,120);
s = awgn(s_org,5,'measured');
% STFRFT 耗时太多是因为它的算法是自己编写的
[shr1,tfrr,tfrrv1] = stfrftSeparation(s,sif,10);%固定窗长度的时变滤波，STFRFT的窗长度可以相对STFT的短很多
[shr2,tfrr,tfrvr2] = stfrftSeparationAdv(s,sif,10);%自适应窗长度的时变滤波
figure;plot(t,real(s_org),'b.-',t,real(s),'g',t,real(shr1),'r.-',t,real(shr2),'k.-'); 
axis tight;legend('orignal','noised','windowed','adaptive');%xlim([1,128])%查看边缘值
figure;subplot(131);imagesc(abs(tfrr)); axis xy; 
subplot(132);imagesc(sum(abs(tfrrv1),3)); axis xy; 
subplot(133);imagesc(sum(abs(tfrvr2),3)); axis xy; 
% % STFT 耗时很少是因为它的算法是系统自带的优化后的
[sh1,tfr,tfrv1] = stftSeparation(s,sif,30);%固定窗长度的时变滤波
[sh2,tfr,tfrv2] = stftSeparationAdv(s,sif,30);%自适应窗长度的时变滤波
% figure;plot(t,real(s_org),'b.-',t,real(s),'g',t,real(sh1),'r.-',t,real(sh2),'k.-'); 
% axis tight;legend('orignal','noised','windowed','adaptive');%xlim([1,128])%查看边缘值
% figure;subplot(131);imagesc(abs(tfr)); axis xy; 
% subplot(132);imagesc(abs(tfrv1)); axis xy; 
% subplot(133);imagesc(abs(tfrv2)); axis xy; 
% % 联合对比STFRFT和STFT的性能
figure;plot(t,real(s_org),'b.-',t,real(s),'g--',t,real(sh2),'k.-',t,real(shr2),'rx-'); 
axis tight;legend('orignal','noised','stft adaptive','stfrft adaptive');%xlim([1,128])%查看边缘值
figure;subplot(121);imagesc(abs(tfrv2)); axis xy; 
subplot(122);imagesc(sum(abs(tfrvr2),3)); axis xy; 
% 这只是定性的对比，定量的对比需要编写循环实现


pause
%% 2.两分量LFM信号的STFRFT域分离
clear all; clc; close all
N=256;  t = 1:N;
[s1, sif1] = fmlin(N,-0.2,0.4,1);
[s2, sif2] = fmlin(N,0.4,-0.1,5);%让他们交叉处幅度提高
s_org = s1+s2;%信号叠加
s = awgn(s_org,5,'measured');%加噪声
[sh2,tfr,tfrv2] = stftSeparationAdv(s,[sif1,sif2],12,tftb_window(51));%自适应窗长度的时变滤波
[shr2,tfrr,tfrvr2] = stfrftSeparationAdv(s,[sif1,sif2],3,tftb_window(127));%自适应窗长度的时变滤波
% 绘图对比
figure;
subplot(211);plot(t,real(s1),'b.-',t,real(s),'g',t,real(sh2(:,1)),'k.-',t,real(shr2(:,1)),'r.-'); 
axis tight;legend('orignal','noised intersect','stft','stfrft');%xlim([1,128])%查看边缘值
subplot(212);plot(t,real(s2),'b.-',t,real(s),'g',t,real(sh2(:,2)),'k.-',t,real(shr2(:,2)),'r.-'); 
axis tight;legend('orignal','noised intersect','stft','stfrft');%xlim([1,128])%查看边缘值
figure;
subplot(131);imagesc(abs(tfr)); axis xy; title('STFT');
subplot(132);imagesc(abs(tfrr(:,:,1))); axis xy; title('STFRFT signal1');
subplot(133);imagesc(abs(tfrr(:,:,2))); axis xy; title('STFRFT signal2');
figure;
subplot(221);imagesc(abs(tfrv2(:,:,1))); axis xy; title('Filtered STFT signal1');
subplot(222);imagesc(abs(tfrv2(:,:,2))); axis xy; title('Filtered STFT signal2');
subplot(223);imagesc(abs(tfrvr2(:,:,1))); axis xy; title('Filtered STFRFT signal1');
subplot(224);imagesc(abs(tfrvr2(:,:,2))); axis xy; title('Filtered STFRFT signal2');



pause
%% 3.三分量LFM信号的分离效果对比
clear all; clc; close all
N=512;  t = 1:N;
[s1, sif1] = fmlin(N,0,0.4,120);
[s2, sif2] = fmlin(N,0.4,0,360);
[s3, sif3] = fmlin(N,0.2,0.2,60);
s_org = s1+s2+s3;%信号叠加
s = awgn(s_org,5,'measured');%加5dB噪声
[sh2,tfr,tfrv2] = stftSeparationAdv(s,[sif1,sif2,sif3],12,tftb_window(51));%自适应窗长度的时变滤波
[shr2,tfrr,tfrvr2] = stfrftSeparationAdv(s,[sif1,sif2,sif3],3,tftb_window(127));%自适应窗长度的时变滤波
% 绘图对比
figure;
subplot(311);plot(t,real(s1),'b.-',t,real(s),'g',t,real(sh2(:,1)),'k.-',t,real(shr2(:,1)),'r.-'); 
axis tight;legend('orignal','noised intersect','stft','stfrft');%xlim([1,128])%查看边缘值
subplot(312);plot(t,real(s2),'b.-',t,real(s),'g',t,real(sh2(:,2)),'k.-',t,real(shr2(:,2)),'r.-'); 
axis tight;legend('orignal','noised intersect','stft','stfrft');%xlim([1,128])%查看边缘值
subplot(313);plot(t,real(s3),'b.-',t,real(s),'g',t,real(sh2(:,3)),'k.-',t,real(shr2(:,3)),'r.-'); 
axis tight;legend('orignal','noised intersect','stft','stfrft');%xlim([1,128])%查看边缘值
figure;
subplot(221);imagesc(abs(tfr)); axis xy; title('STFT');axis off
subplot(222);imagesc(abs(tfrr(:,:,1))); axis xy; title('STFRFT signal1');axis off
subplot(223);imagesc(abs(tfrr(:,:,2))); axis xy; title('STFRFT signal2');axis off
subplot(224);imagesc(abs(tfrr(:,:,3))); axis xy; title('STFRFT signal3');axis off
figure;
subplot(231);imagesc(abs(tfrv2(:,:,1))); axis xy; title('Filtered STFT signal1');axis off
subplot(232);imagesc(abs(tfrv2(:,:,2))); axis xy; title('Filtered STFT signal2');axis off
subplot(233);imagesc(abs(tfrv2(:,:,3))); axis xy; title('Filtered STFT signal3');axis off
subplot(234);imagesc(abs(tfrvr2(:,:,1))); axis xy; title('Filtered STFRFT signal1');axis off
subplot(235);imagesc(abs(tfrvr2(:,:,2))); axis xy; title('Filtered STFRFT signal2');axis off
subplot(236);imagesc(abs(tfrvr2(:,:,3))); axis xy; title('Filtered STFRFT signal3');axis off


pause
%% 4.2LFM+1SFM信号的恢复效果对比
clear all; clc; close all
N=256;  t = 1:N;
[s1, sif1] = fmlin(N,0.05,0.35,120);
[s2, sif2] = fmlin(N,0.1,0.4,1);
[s3, sif3] = fmsin(N,-0.35,-0.1,256);
s_org = s1+s2+s3;%信号叠加
s = awgn(s_org,2,'measured');%加5dB噪声
[sh2,tfr,tfrv2] = stftSeparationAdv(s,[sif1,sif2,sif3],13,tftb_window(51));%自适应窗长度的时变滤波
[shr2,tfrr,tfrvr2] = stfrftSeparationAdv(s,[sif1,sif2,sif3],3,tftb_window(127));%自适应窗长度的时变滤波
% 绘图对比
figure;
subplot(311);plot(t,real(s1),'b.-',t,real(s),'g',t,real(sh2(:,1)),'k.-',t,real(shr2(:,1)),'r.-'); 
axis tight;legend('orignal','noised intersect','stft','stfrft');xlim([28,128])%查看边缘值
subplot(312);plot(t,real(s2),'b.-',t,real(s),'g',t,real(sh2(:,2)),'k.-',t,real(shr2(:,2)),'r.-'); 
axis tight;legend('orignal','noised intersect','stft','stfrft');xlim([1,128])%查看边缘值
subplot(313);plot(t,real(s3),'b.-',t,real(s),'g',t,real(sh2(:,3)),'k.-',t,real(shr2(:,3)),'r.-'); 
axis tight;legend('orignal','noised intersect','stft','stfrft');xlim([28,128])%查看边缘值
figure;
subplot(221);imagesc(abs(tfr)); axis xy; title('STFT');axis off
subplot(222);imagesc(abs(tfrr(:,:,1))); axis xy; title('STFRFT signal1');axis off
subplot(223);imagesc(abs(tfrr(:,:,2))); axis xy; title('STFRFT signal2');axis off
subplot(224);imagesc(abs(tfrr(:,:,3))); axis xy; title('STFRFT signal3');axis off
figure;
subplot(231);imagesc(abs(tfrv2(:,:,1))); axis xy; title('Filtered STFT signal1');axis off
subplot(232);imagesc(abs(tfrv2(:,:,2))); axis xy; title('Filtered STFT signal2');axis off
subplot(233);imagesc(abs(tfrv2(:,:,3))); axis xy; title('Filtered STFT signal3');axis off
subplot(234);imagesc(abs(tfrvr2(:,:,1))); axis xy; title('Filtered STFRFT signal1');axis off
subplot(235);imagesc(abs(tfrvr2(:,:,2))); axis xy; title('Filtered STFRFT signal2');axis off
subplot(236);imagesc(abs(tfrvr2(:,:,3))); axis xy; title('Filtered STFRFT signal3');axis off




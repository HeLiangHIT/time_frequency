function TVF_Compare_fixAda_window_STFT
% 对比基于STFT的自适应和固定窗TVF的RMSE性能：在SFM和 LFM两种信号下对比

clear all; clc; close all
N=256; testN = 100; SNR = -20:2:20;%dB--仿真参数设置
% % AM-FM信号测试
% [sfm, sif] = fmlin(N,0,0.5,50);%plot(real(sfm))
% sam = (cos(0.05*(1:N))+2)/3;%plot(sam)
% s_org = sfm.*sam.';%plot(real(s)) % 幅度调制

% 蒙特卡洛仿真
rmse1 = zeros(length(SNR),2);%两个算法对比
[s_org,sif] = fmlin(N,0.1,0.4,120);
for k = 1:length(SNR)
    for n = 1:testN
        s = awgn(s_org,SNR(k),'measured');
        [sh1,tfr,tfrv1] = stftSeparation(s,sif,10);%固定窗长度的时变滤波
        [sh2,tfr,tfrv2] = stftSeparationAdv(s,sif,10);%自适应窗长度的时变滤波，参数设置不合理其性能可能下降
        rmse1(k,1)=rmse1(k,1) + sqrt(mean(abs(sh1-s_org).^2));
        rmse1(k,2)=rmse1(k,2) + sqrt(mean(abs(sh2-s_org).^2));
    end
    rmse1(k,:) = rmse1(k,:)/testN;
end
figure(1);plot(SNR,rmse1(:,1),'b^-',SNR,rmse1(:,2),'rv-');hold on;

rmse2 = zeros(length(SNR),2);%两个算法对比
[s_org,sif] = fmsin(N,0.1,0.4,N);
for k = 1:length(SNR)
    for n = 1:testN
        s = awgn(s_org,SNR(k),'measured');
        [sh1,tfr,tfrv1] = stftSeparation(s,sif,15);%固定窗长度的时变滤波
        [sh2,tfr,tfrv2] = stftSeparationAdv(s,sif,15);%自适应窗长度的时变滤波，参数设置不合理其性能可能下降
        rmse2(k,1)=rmse2(k,1) + sqrt(mean(abs(sh1-s_org).^2));
        rmse2(k,2)=rmse2(k,2) + sqrt(mean(abs(sh2-s_org).^2));
    end
    rmse2(k,:) = rmse2(k,:)/testN;
end
figure(1);plot(SNR,rmse2(:,1),'b.-',SNR,rmse2(:,2),'ro-');legend('固定窗TVF-LFM','自适应窗TVF-LFM','固定窗TVF-SFM','自适应窗TVF-SFM');
xlabel('SNR/dB');ylabel('RMSE');set_gca_style([12,6]);

Results_File = ['TVF_fix_and_ada_window',datestr(clock,'_yyyy_mm_dd_hh_MM')];
save(Results_File,'SNR','rmse1','rmse2');

end


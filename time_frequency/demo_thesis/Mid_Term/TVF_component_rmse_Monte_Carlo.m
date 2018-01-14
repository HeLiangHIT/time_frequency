function rmse = TVF_component_rmse_Monte_Carlo(s_org,s_cpnt,sif,SNR,testN, LenStft, LenStfrft, LenOverlap)
%% 进行多分量信号分离的蒙特卡洛仿真，对比STFT-FIX/STFT-ADA/STFT-ADA-MOD/STFRFT-FIX/STFRFT-ADA/STFRFT-ADA-MOD
% 输入参数：s_org 表示输入的叠加信号，必须无噪声否则不符合蒙特卡洛原理
% s_cpnt 表示输入的信号分量矩阵，每一列表示一个信号分量
% sif 表示输入的信号瞬时频率矩阵，每一列对应一个信号分量
% SNR 需要仿真的SNR向量
% testN 需要仿真的次数
%rmse：返回的1-8个分量分别为 STFT-FIX/STFT-FIX-MOD/STFT-ADA/STFT-ADA-MOD/STFRFT-FIX/STFRFT-FIX-MOD/STFRFT-ADA/STFRFT-ADA-MOD

% 常量参数
if  nargin < 6 ;LenStft = 10;end% STFT的窗长度
if  nargin < 7 ;LenStfrft = round(0.5*LenStft); end;%STFRFT的窗长度
if  nargin < 8 ;LenOverlap = round(3*LenStft); end % 假设的叠加信号长度范围

%testN = 100; SNR = -20:2:20;%dB--仿真参数设置
sigN = size(s_cpnt,2);
LEN_SNR = length(SNR);
rmse = zeros(LEN_SNR,sigN,8);%两个算法对比
for k = 1:LEN_SNR
    fprintf('TVF_component_rmse_Monte_Carlo, snr = %d / %d , ',SNR(k),SNR(end));tic
    for n = 1:testN
        s = awgn(s_org,SNR(k),'measured');
        % 算法实现
        [sh1,tfr,tfrv1] = stftSeparation(s,sif,LenStft);%固定窗长度
        %sh2 = amplitudeFit(sh1, tfr, tfrv1, 1);%imagesc(abs(tfr))
        sh2 = amplitudeInterp(sh1, sif, LenOverlap, 1);%采用幅度插值的方式恢复--会有相位失真
        
        [sh3,tfr,tfrv2] = stftSeparationAdv(s,sif,LenStft);%自适应窗长度的时变滤波，参数设置不合理其性能可能下降
        %sh4 = amplitudeFit(sh3, tfr, tfrv2, 1);%imagesc(abs(tfrv1(:,:,3))); figure; imagesc(abs(tfrv2(:,:,3)))
        sh4 = amplitudeInterp(sh3, sif, LenOverlap, 1);
        
        [sh5,tfrTmp,tfrvTmp] = stfrftSeparation(s,sif,LenStfrft);%固定窗长度
        %sh6 = amplitudeFit(sh5,tfr,tfrv2,1);%imagesc(abs(tfrTmp(:,:,1)));figure;imagesc(abs(tfrvTmp(:,:,1)));
        sh6 = amplitudeInterp(sh5, sif, LenOverlap, 1);
        
        [sh7,tfrTmp,tfrvTmp] = stfrftSeparationAdv(s,sif,LenStfrft);%自适应窗长度的时变滤波--FRFT能量更集中，因此需要的宽度更小
        %sh8 = amplitudeFit(sh7, tfr, tfrv2, 1);%imagesc(abs(tfrTmp(:,:,1)));figure;imagesc(abs(tfrvTmp(:,:,1)));
        sh8 = amplitudeInterp(sh7, sif, LenOverlap, 1);
        
        %结果统计
        for sign = 1:sigN
            rmse(k,sign,1)=rmse(k,sign,1) + sqrt(mean(abs(sh1(:,sign)-s_cpnt(:,sign)).^2));
            rmse(k,sign,2)=rmse(k,sign,2) + sqrt(mean(abs(sh2(:,sign)-s_cpnt(:,sign)).^2));
            rmse(k,sign,3)=rmse(k,sign,2) + sqrt(mean(abs(sh3(:,sign)-s_cpnt(:,sign)).^2));
            rmse(k,sign,4)=rmse(k,sign,4) + sqrt(mean(abs(sh4(:,sign)-s_cpnt(:,sign)).^2));
            rmse(k,sign,5)=rmse(k,sign,5) + sqrt(mean(abs(sh5(:,sign)-s_cpnt(:,sign)).^2));
            rmse(k,sign,6)=rmse(k,sign,6) + sqrt(mean(abs(sh6(:,sign)-s_cpnt(:,sign)).^2));
            rmse(k,sign,7)=rmse(k,sign,7) + sqrt(mean(abs(sh7(:,sign)-s_cpnt(:,sign)).^2));
            rmse(k,sign,8)=rmse(k,sign,8) + sqrt(mean(abs(sh8(:,sign)-s_cpnt(:,sign)).^2));
        end
    end
    fprintf('用时 %f s, 预计剩余 %.3f min \n',toc, toc*(LEN_SNR-k)/60);
    rmse(k,:) = rmse(k,:)/testN;
end

end
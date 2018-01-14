function rmse = TVF_component_rmse_Monte_Carlo_STFRFT(s_org,s_cpnt,sif,SNR,testN)
%% 进行多分量信号分离的蒙特卡洛仿真，采用STFRFT自适应窗长度
% 输入参数：s_org 表示输入的叠加信号，必须无噪声否则不符合蒙特卡洛原理
% s_cpnt 表示输入的信号分量矩阵，每一列表示一个信号分量
% sif 表示输入的信号瞬时频率矩阵，每一列对应一个信号分量
% SNR 需要仿真的SNR向量
% testN 需要仿真的次数

%testN = 100; SNR = -20:2:20;%dB--仿真参数设置
sigN = size(s_cpnt,2);
rmse = zeros(length(SNR),sigN);%两个算法对比
LEN_SNR = length(SNR);
for k = 1:LEN_SNR
    fprintf('TVF_component_rmse_Monte_Carlo, snr = %d / %d , ',SNR(k),SNR(end));tic
    for n = 1:testN
        s = awgn(s_org,SNR(k),'measured');
        [sh2,tfr,tfrv2] = stfrftSeparationAdv(s,sif,8);%自适应窗长度的时变滤波，参数设置不合理其性能可能下降
        for sign = 1:sigN
            rmse(k,sign)=rmse(k,sign) + sqrt(mean(abs(sh2(:,sign)-s_cpnt(:,sign)).^2));
        end
    end
    fprintf('用时 %f s, 预计剩余 %.3f min \n',toc, toc*(LEN_SNR-k)/60);
    rmse(k,:) = rmse(k,:)/testN;
end

end
% CS理论去掉压缩采样，只考虑重构的算法，那么对于均匀满足采样定理的信号，如何重构的问题需要考虑一下。
% 增加统计RMSE
% 4-44MHz 1us LFM fs=400MHz 信噪比-5~5dB 信号重构分析 整理一下给我 评估


clc;clear all; close all;
N=512;%采样点数
t=1:N;
f=linspace(0,0.5,N);
T0 = N/2;%其实参考相位位置
K_OMP = 1;
nTest = 200;
SNR = [-10:1:10];
K_START = 0.02;
K_LFM = 0.22;%LFM斜率*N，最大值0.5

corcef = zeros(length(K_LFM),length(SNR));
RMSE = zeros(length(K_LFM),length(SNR));
for iK=1:length(K_LFM)
    % 参数计算
    k_lfm=(K_LFM(iK)-K_START)/(N-1);%LFM斜率
    p = mod(2/pi*acot(-k_lfm*N),2);% FRFT阶数，归一到0-2之间
    % 正交基构造
    bais=eye(N,N);
    Psi = zeros(size(bais));
    for k = 1:N
        Psi(:,k) = frft(bais(:,k),p)*sqrt(N);%对各列基作FRFT变换
    end
    
    fprintf('sim k = %0.4f\n',K_LFM(iK));
    for iT = 1:nTest
        for iSnr = 1:length(SNR)
            % 信号产生
            [sig1,if1] = fmlin(N,K_START,K_LFM(iK),T0);
            [sig2,if2] = fmlin(N,0.3,-0.3,T0);%叠加分量
            x_org = sig1 + 6*sig2;%legend('I=4','I=5','I=6');
            x = awgn(x_org,SNR(iSnr),'measured'); %添加噪声
            % OMP重构
            T=Psi';           %  恢复矩阵(测量矩阵*正交反变换矩阵)，y=恢复矩阵*s。其中y为观测数据，s为稀疏表示系数
            [hat_y1,r_n] = omp(x,T,N,K_OMP);%OMP算法重构1个分量
            hat_s1=Psi'*hat_y1.';                         %  做逆傅里叶变换重构得到时域信号
            
            %误差分析
            % plot(t,real(sig1),'b.-');hold on; plot(t,real(x),'k+-'); plot(t,real(hat_s1),'o-r'); legend('信号分量','受污染的信号','重构的分量'),axis tight
            RMSE(iK,iSnr) = RMSE(iK,iSnr) + norm(hat_s1 - sig1, 'fro')/norm(sig1,'fro') ;
            cor = corrcoef(hat_s1, sig1);%相关系数
            corcef(iK,iSnr) = corcef(iK,iSnr) + abs(cor(1,2)) ;%保存
        end
    end
end

%结果整理
RMSE = mean(RMSE,1)/nTest;
corcef = mean(corcef,1)/nTest;
% figure,plot(SNR,RMSE,'b.-'); xlabel('SNR/dB');ylabel('RMSE')
figure,plot(SNR,corcef,'b.-');xlabel('SNR/dB');ylabel('correlative coefficient')
% 结果分析：从TFR看SNR=0dB时根本就已经无法恢复各个分量的信号了，
% 而采用稀疏域方法恢复的信号却非常完美！！至少相关度很好！！


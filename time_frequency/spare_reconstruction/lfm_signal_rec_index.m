% CS理论去掉压缩采样，只考虑重构的算法，那么对于均匀满足采样定理的信号，如何重构的问题需要考虑一下。
% 选择评价指标的测试脚本

clc;clear all; close all;
N=512;%采样点数
t=1:N;
f=linspace(0,0.5,N);
T0 = N/2;%其实参考相位位置
nGet = 1;%OMP每次提取多少个分量

nTest = 10;
SNR = [-30:3:20];
K_LFM = -0.5:0.2:0.5;%LFM斜率*N，最大值0.5


RMSE = zeros(length(K_LFM),length(SNR));
MSE = zeros(length(K_LFM),length(SNR));
corcef = zeros(length(K_LFM),length(SNR));
for iK=1:length(K_LFM)
    % 参数计算
    k_lfm=K_LFM(iK)/N;%LFM斜率
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
            [sig1,if1] = fmlin(N,0,K_LFM(iK),T0);
            %         [sig2,if2] = fmlin(N,0.2,0.5,T0);%叠加分量
            [sig2,if2] = fmconst(N,0.2,T0);%叠加分量
            x_org = sig1;% + sig2;
            x = awgn(x_org,SNR(iSnr),'measured'); %添加噪声
            % OMP重构
            T=Psi';           %  恢复矩阵(测量矩阵*正交反变换矩阵)，y=恢复矩阵*s。其中y为观测数据，s为稀疏表示系数
            [hat_y1,r_n] = omp(x,T,N,nGet);%OMP算法重构1个分量
            hat_s1=Psi'*hat_y1.';                         %  做逆傅里叶变换重构得到时域信号
            
            %误差分析
            % plot(t,real(sig1),'b.-');hold on; plot(t,real(x),'k+-'); plot(t,real(hat_s1),'o-r');legend('信号分量','受污染的信号','重构的分量'),axis tight
            RMSE(iK,iSnr) = RMSE(iK,iSnr) + norm(hat_s1 - sig1, 'fro')/norm(sig1,'fro') ;
            MSE(iK,iSnr) = MSE(iK,iSnr) + norm(hat_s1 - sig1, 'fro');
            cor = corrcoef(hat_s1, sig1);%相关系数
            corcef(iK,iSnr) = corcef(iK,iSnr) + abs(cor(1,2)) ;%保存
        end
    end
end

%结果整理
RMSE = mean(RMSE,1)/nTest;
MSE = mean(MSE,1)/nTest;
corcef = mean(corcef,1)/nTest;

figure,plot(SNR,RMSE,'b.-'); %这个指标在信噪比很大时效果很差，信噪比很小时评价效果较好
figure,plot(SNR,MSE,'b.-'); %这个指标评价时忽略了输入信号的分量干扰，因此评价结果比较合理
figure,plot(SNR,corcef,'b.-');%这个指标用于相关接收机时评价效果非常合理




%% 单分量信号的相位恢复
% fmlin和fmsin的初始相位指定都没有，无法实现，如果要做的话需要根据信号表达式。

clear all; clc;
%% 参数初始化
N = 128;
F0 = 0.1;
K = (0.4-F0)/N;
flin = @(t,p) exp(1i*(2*pi*F0*t + pi*K*t.^2 + p));%LFM表达式

%% 信号产生
% figure(1)
pO = pi;
t = 1:N;
s_org = flin(t,pO);%tfrsp(s_org.');
% subplot(211);plot(real(s_org)); axis tight;
s = awgn(s_org,10,'measured');
% subplot(212);plot(real(s)); axis tight;

%% 验证MMSE的单调性
% pT = 0:0.001:2*pi;
% for pt = 1:length(pT)
%     sT = flin(t,pT(pt));
%     err(pt) = std(sT - s);
%     %err(pt) = sum((sT - s).^2);
% end
% plot(pT,err,'kx-');axis tight; grid on; xlabel('phase'); ylabel('MSE'); hold on;% legend('p_{org} = 0','p_{org} = 1','p_{org} = 2','p_{org} = 3','p_{org} = 4','p_{org} = 5');
% % 结论：均方误差和相位在一周期0-2pi内是单调的，只有一个极值点，但是在求解的时候越界的需要2pi位移


%% 相位计算
% figure(2)
% err=inf;
% p_hat = pi;
% miu = 0.99999;
% while err(end) > 1e-3*std(s)
%     sh = flin(t,p_hat(end));
%     er1 = sh - s;
%     p_vec = (er1 - mean(er1)).*(1j*sh - 1j * mean(sh));
%     p_dir = mean(p_vec);
%     miu = miu;
%     p_hat(end+1) = p_hat(end) - miu * p_dir; %循环
%     subplot(211);plot(abs(p_hat));axis tight; title('abs(p)')
%     err(end+1) = std(er1);
%     subplot(212);plot(err); axis tight; title('stdErr')
%     pause(0.01)
% end
% p_hat = p_hat(end);%模拟相位计算结果
% s_hat = flin(t,p_hat);
% subplot(211);plot(real(s)); axis tight;


%% MSE计算公式：参考《时变滤波及信号合成》式7.10
sh = flin(t,0);%随便估计一个初始相位即可
% figure;tfrsp(sh.');%可以发现初始相位不会影响TFRWV的值
pf = sum(s.*conj(sh));
pf = pf/abs(pf);% 公式
sh = sh.*pf;
subplot(211);plot(t,real(s_org),'k.-',t,real(s),'gx-', t,real(sh),'ro-'); axis tight; legend('原始信号','加噪信号','恢复信号');
subplot(212);plot(t,imag(s_org),'k.-',t,imag(s),'gx-', t,imag(sh),'ro-'); axis tight; legend('原始信号','加噪信号','恢复信号');
% >>可行！！

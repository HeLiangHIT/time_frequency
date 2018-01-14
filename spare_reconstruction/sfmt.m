function [X, s_hat] = sfmt(s, k0, l0 )
%% 正弦调频变换，当输入k0/l0时表示计算指定位置的值，
% 参考：孙志国, 陈晶, 曹雪, et al. 基于离散正弦调频变换的多分量正弦调频信号参数估计方法[J]. 系统工程与电子技术, 2012(10): 1973-1979.
% 输入：s原始信号，一行或者一列
% 输出：X是SFMT谱或者单个值，s_hat，就是SFMT谱峰值对应的SFM信号
% 测试脚本1：% clear all; clc
% N = 128;
% k0 = 1;
% l0 = 16;
% t = [0:N-1]';
% s = exp(1i*l0/k0*sin(2*pi*k0*t/N));%plot(t,real(s),'.-') %公式5，已知k0和l0时恢复原始信号的方法
% % stft = tfrstft(s);imagesc(abs(stft));
% [X,s_hat] = sfmt(s);
% stft = tfrstft(s_hat);imagesc(abs(stft));%可以发现此处正确
% 测试脚本2：
% s = fmsin(128);
% [X, s_hat] = sfmt(s);
% stft = tfrstft(s_hat);imagesc(abs(stft));%可以发现此处不正确>>在存在f0的情况下会错误

% 参数初始化
s = s(:);
N = length(s);
t = [0:N-1]';
norfmsin =@(k,l,t,N) exp(-1j*l/k*sin(2*pi*k*t/N));% 权重信号

if nargin>=2%输入>=2时只计算特定点的值
    assert(k0<=N && k0>=1 && mod(k0,1)==0 , '输入的k0必须为整数且范围为1到N之间！');
    assert(l0<=N && l0>=1 && mod(l0,1)==0 , '输入的l0必须为整数且范围为1到N之间！');
    fms = norfmsin(k0,l0,t,N);%产生权重信号
    X = sum(s.*fms);
else%否则计算整个SFMT谱
    X = zeros(N);
    for k = 1:1:N
        for l = 1:1:N
            fms = norfmsin(k,l,t,N);%产生权重信号
            X(k,l) = sum(s.*fms);
        end
    end
%     surf(abs(X));axis tight; xlabel('l'); ylabel('k')
    [ko,lo] = find(X == max(X(:)));
    s_hat = norfmsin(ko,-lo,t,N);%产生权重信号
end



end

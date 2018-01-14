function [s,s_itfr,s_org,iflaw] = signalGenSS()
%% 产生一个复杂的叠加信号，并输出其理想时频分布。
% 输出解析信号s，输出其理想时频分布s_itfr
% 注：参数控制可以参考如下用法：
% a = {@fmlin, @fmconst};%函数句柄cell作为输入
% s = a{1}(60,0.3,0.1,1);%函数值cell作为各个函数的输入
% 注：更好的解决方案是使用函数：fmodany，只需要设计iflaw就行了

%总体参数
N = 512;%信号采样点数
% fs = 1e6;%假设为1M采样率，可以用于产生采样时间t


%% SIN调频信号产生
t1=1;
[s1,if1]=fmsin(511,0.1,0.4,128,1,0.1,1);%(N,FNORMIN,FNORMAX,PERIOD,T0,FNORM0,PM1)
s_org{1} = [zeros(t1,1);s1;zeros(N-t1-length(s1),1)];
[s1,if1]= insert_signal(s1,N,t1,if1);

t2=1;
[s2,if2]=fmsin(511,0.1,0.4,128,1,0.4,1);%(N,FNORMIN,FNORMAX,PERIOD,T0,FNORM0,PM1)
s_org{2} = [zeros(t2,1);s2;zeros(N-t2-length(s2),1)];
[s2,if2]= insert_signal(s2,N,t2,if2);


%% 输出
s =(s1+s2).';%
iflaw=[if1;if2].';%
if nargout < 1
    figure,tfrideal(iflaw);%理想信号时频分布
else
    s_itfr = tfrideal(iflaw);%理想信号时频分布
end

end


function [s,s_if] = insert_signal(sig,N,t0,sig_if)
% 将信号sig插入到一个N长度的0信号中，起始点为t0，输出信号s
if nargin < 1
    s = [];
elseif nargin < 2
    s = sig(:).';%输入信号必须是一维的
elseif nargin < 3
    assert(N>=length(sig),'信号长度%d>输出长度,，无法插入！%d',length(sig),N);
    
    s = [sig(:),zeros(N-length(sig),1)].';%输入信号必须是一维的
elseif nargin < 4
    assert(N>=length(sig),'信号长度%d>输出长度%d，无法插入！%d',length(sig),N);
    assert(t0<=N-length(sig),'起始位置%d>输出长度-信号长度，无法插入！%d',t0,N-length(sig));
    
    s = [zeros(t0,1);sig(:);zeros(N-length(sig)-t0,1)].';%输入信号必须是一维的
else
    assert(length(sig) == length(sig_if),'信号长度必须等于其瞬时频率长度！');
    assert(N>=length(sig),'信号长度%d>输出长度%d，无法插入！%d',length(sig),N);
    assert(t0<=N-length(sig),'起始位置%d>输出长度-信号长度，无法插入！%d',t0,N-length(sig));
    
    s = [zeros(t0,1);sig(:);zeros(N-length(sig)-t0,1)].';%输入信号必须是一维的
    s_if = [NaN*zeros(t0,1);sig_if(:);NaN*zeros(N-length(sig)-t0,1)].';%输入信号必须是一维的
end

end


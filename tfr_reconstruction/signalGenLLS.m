function [s,s_itfr,s_org,iflaw] = signalGenLLS()
%% 产生一个复杂的叠加信号，并输出其理想时频分布。
% 输出解析信号s，输出其理想时频分布s_itfr
% 注：参数控制可以参考如下用法：
% a = {@fmlin, @fmconst};%函数句柄cell作为输入
% s = a{1}(60,0.3,0.1,1);%函数值cell作为各个函数的输入
% 注：更好的解决方案是使用函数：fmodany，只需要设计iflaw就行了

%总体参数
N = 512;%信号采样点数
% fs = 1e6;%假设为1M采样率，可以用于产生采样时间t

%% LFM信号：不同位置的两个LFM信号
t1 = 100;%LFM1起始点
[s1,if1]=fmlin(400,0.2,0.05,1);%线性调频信号，其0相位为第一个采样点
s_org{1} = [zeros(t1,1);s1;zeros(N-t1-length(s1),1)];
[s1,if1] = insert_signal(s1,N,t1,if1);


t2 = 10;%LFM2起始点
[s2,if2]=fmlin(250,0.25,0.45,1);%线性调频信号，其0相位为第1个采样点
s_org{2} = [zeros(t2,1);s2;zeros(N-t2-length(s2),1)];
[s2,if2]= insert_signal(s2,N,t2,if2);

%% SIN调频信号产生
t4=200;
[s4,if4]=fmsin(300,0.2,0.32,200,1,0.28,1);%(N,FNORMIN,FNORMAX,PERIOD,T0,FNORM0,PM1)
s_org{3} = [zeros(t4,1);s4;zeros(N-t4-length(s4),1)];
[s4,if4]= insert_signal(s4,N,t4,if4);

%% 固定频率信号
% t5 = 50;
% [s5,if5]=fmconst(300,0.1);
% [s5,if5]= insert_signal(s5,N,t5,if5);

%% 输出
s =(s1+s2+s4).';%s =(s1+s2+s3 +s4+s5).';
iflaw=[if1;if2;if4].';%iflaw=[if1;if2;if3;if4;if5].';
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


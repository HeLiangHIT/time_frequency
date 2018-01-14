
%% IF估计测试
clear all; clc, close all;

%% 单分量信号产生和估计
N=312;
t = 1:N;
[s_org,rif]=fmsin(N,0.15,0.45,200,1,0.35,1);%周期为100，相位0点为1，t0处的频率为0.35，频率方向为正
s = awgn(s_org,5,'measured');
if1 = zce( s, 64);plot(t,if1,'b.-'); hold on
if2 = wvpe(s, 127, 1);plot(t,if2,'r.-');
if3 = pwvpe(s,127,1,8);plot(t,if3,'k.-');
if4 = rls(s,0.5);plot(t,if4,'bx-');
if6 = lms(s,0.5);plot(t,if6,'kx-');
if7 = sfpe (s, 127, 1);plot(t,if7,'rsquare-');
legend('zce','wvpe','pwvpe','rls','lms','sfpe');axis tight
% 测试发现ZCE和WVPE较好，而wvpe可以输入已经计算好的TFD>>失败，并不可以






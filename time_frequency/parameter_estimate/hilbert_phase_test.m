%% 测试希尔伯特变换求解瞬时相位是否可靠
% 结论：会存在周期性的规律误差，误差会累计影响后面的测量结果。

clear;close all;clc

% 信号产生
t=0:0.01:30;
Phase = t+cos(t);
phase = mod(Phase,2*pi);
y=cos(Phase);

% 相位求解
xhat=hilbert(y);
Pha=angle(xhat);%phase of signal，希尔伯特变换得到的瞬时相位是包裹相位
pha=unwrap(Pha);%Correct pha angles
figure(1)
plot(t,Pha,'.-r',t,pha,'.-r',t,Phase,'k-x',t,phase,'k-x');
legend('uncorrected','corrected','real uncorrected','real corrected');



figure(2)
Phase1 = t;
Phase2 = cos(2*t);
y=cos(Phase1)+cos(Phase2);
xhat=hilbert(y);
Pha=angle(xhat);%phase of signal
pha=unwrap(Pha);%Correct pha angles
figure(2)
plot(t,Phase1,'.-b',t,Phase2,'o-r',t,pha,'k-p');
legend('Phase1','Phase2','messured');



%% 参考：Rankine L, Mesbah M, Boashash B. 
% IF estimation for multicomponent signals using image processing techniques in the time–frequency domain [J]. 
% Signal Process, 2007, 87(6): 1234-50.
% 第2.2节的实现参数
%% 评价，多次迭代后信号衰减很强，这个方法只适合少数迭代。
% 该TFPF方法很巧妙的将实数信号作为IF信息来估计，但是其实效果都不如使用低通滤波或者时变滤波呢。
% 只能算作是一种信号增强算法，也算是【IF估计的应用场景之一】。

%% 测试时频峰值滤波的信号增强
clear all; close all; clc
N = 512; t = 1:N; Fs = 1;
maxf = 0.08;
s_org = fmlin(N,0.01,maxf);%最大0.05的信号频率
s = awgn(s_org,5,'measured');
x = real(s); xt = x;

for k=1:1
    [y,tfr] = tfpf_iter_org(xt,maxf);
%     [y,tfr] = tfpf_ref(xt,9,0.9);
    plot(t,real(s_org),'bx-',t,x,'g',t,y,'r.-');axis tight;legend('原始信号','带噪声信号','增强的信号')
    pause(0.05)
    xt = y;
end


%% 多分量信号的滤波
clear all; close all; clc
N = 512; t = 1:N; Fs = 1;
maxf = 0.4;
s_org = fmlin(N,0.01,0.1) + fmsin(N,0.12,0.28) + fmlin(N,0.3,0.4);%最大0.05的信号频率
s = awgn(s_org,0,'measured');%tfrspwv(s);
x = real(s); 

xt = x;
for k=1:4
    %[y,tfr] = tfpf_iter_org(xt,maxf);
    [y,~] = tfpf_iter(xt,maxf);tfr = tfrspwv(hilbert(y.'));
    subplot(4,1,1:3);imagesc(abs(tfr));axis xy;pause(0.1)
    subplot(4,1,4);plot(t,real(s_org),'bx-',t,x,'g',t,y,'r.-');axis tight;legend('原始信号','带噪声信号','增强的信号')
    pause(0.05)
    xt = y;
end




%% TFR增强方法：WVD和SPWVD组合
% clear all; close all; clc
% N = 512; t = 1:N; Fs = 1;
% s_org = fmlin(N,0.01,0.45) + fmlin(N,0.41,0.05) ;%最大0.05的信号频率
% s = awgn(s_org,10,'measured');
% tf1 = tfrwv(s);
% tf2 = tfrspwv(s);
% tf = tf1.*tf2;
% subplot(131);imagesc(tf1);
% subplot(132);imagesc(tf2);
% subplot(133);imagesc(tf);









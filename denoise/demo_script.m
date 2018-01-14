%% ref: Rankine L, Mesbah M, Boashash B. 
% IF estimation for multicomponent signals using image processing techniques in the time¨Cfrequency domain [J]. 
% Signal Process, 2007, 87(6): 1234-50.

%% signal generate
clear all; close all; clc
N = 512; t = 1:N; Fs = 1;
maxf = 0.08;
s_org = fmlin(N,0.01,maxf);%use a lfm simply
s = awgn(s_org,5,'measured');
x = real(s);


xt = x;
for k=1:20
    [y,tfr] = tfpf_iter(xt,maxf);
    plot(t,real(s_org),'bx-',t,x,'g',t,y,'r.-');axis tight;legend('orignal','noised','reconstructed')
    pause(0.05)
    xt = y;
end





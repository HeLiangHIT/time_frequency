function QTFR_Kernels_tfr
%% script 对比不同QTFR设计核下的TFR

clear all; clc; close all
%% 测试信号
t=1:256;    % 256 samples.
sig = 1* cos(2*pi*(0.0006)*t.*t+2*pi*0.1*t)+1*sin(-1*pi*0.03*t)+1*sin(2*pi*0.08*t)+cos(2*pi*(0.0006)*t.*t+2*pi*(0.15)*t);
N=length(sig);   
[IAF, WV]=wvdClean(sig,N);% 计算AF域
figure('Name','WVD');imagesc(abs(WV));axis xy; %colormap('hot');axis off;set_gca_style([4,4],'img');
figure('Name','IAF');imagesc(abs(IAF));axis xy; %colormap('hot');axis off;set_gca_style([4,4],'img');


%% EMBD核
display('EMBD');
g=ifftshift(extnd_mbd(0.1,0.1,0.5,256));
% Calling Wigner-Ville Distribution .. Md.A
am=IAF.*g;                             % Applying EMBD kernel to ambiguity domain function Md.A
tfd1 = (fft(ifftshift(am,1), [], 1));
tfd1=  ifft(fftshift(tfd1,2), [], 2);
% tfd1=real(tfd1); tfd1(tfd1<0)=0;  figure;tfsapl(sig,tfd1, 'Title','EMBD', 'GrayScale','on') 
figure('Name','EMBD核');imagesc(abs(g));axis xy; %colormap('hot');axis off;set_gca_style([4,4],'img');
figure('Name','EMBD核*IAF');imagesc(abs(am));axis xy; %colormap('hot');axis off;set_gca_style([4,4],'img');
figure('Name','EMBD核的TFR');imagesc(abs(tfd1));axis xy; %colormap('hot');axis off;set_gca_style([4,4],'img');


%% CKD核
display('CKD');
% Defining Parameters
C=1;                              % parameters C controls the shape of kernel
D=0.09;                           % parameters D, E controls the spread of kernel 
E=0.05; 
g=cskabedbelchourini(length(sig),C,D,E);  % CKD Kernel
% figure;tfsapl(sig,WV,'Title','WVD', 'GrayScale','on');%WVD分布
am=IAF.*g;                                % Applying CKD kernel to ambiguity domain function ... 
tfd1 = (fft(ifftshift(am,1), [], 1));
tfd1=  ifft(fftshift(tfd1,2), [], 2);
% tfd1=real(tfd1);
% tfd1(tfd1<0)=0;                   %   Values less than 0 are discarded .. 
% figure;tfsapl(sig,tfd1, 'Title','CKD', 'GrayScale','on') %绘制最终的分布函数
figure('Name','CKD核');imagesc(abs(g));axis xy; %colormap('hot');axis off;set_gca_style([4,4],'img');
figure('Name','CKD核*IAF');imagesc(abs(am));axis xy; %colormap('hot');axis off;set_gca_style([4,4],'img');
figure('Name','CKD核的TFR');imagesc(abs(tfd1));axis xy; %colormap('hot');axis off;set_gca_style([4,4],'img');


%% MDD核--这个核很适合用来设计针对多分量LFM信号滤波
display('MDD');
% Input Parameters for MDD     . 
theta(1)=90;       % Angle one     .. 
theta(2)=60;       % Angle two
tau(1)=0.5;        % parameter to reduce the effect of inner-terms  
tau(2)=0.5;
c= 1;              % parameter to adjust the form of shape ... 
D=0.015;           % parameter to adjust the size of window .. 
% Calling MDD
g=proposedkernel(sig, theta,tau,c,D); %MDD kernel.. 
am=IAF.*g;           % Applying MDD kernel to ambiguity domain function 
% Code for MDD
tfd = (fft(ifftshift(am,1), [], 1));
tfd1=  ifft(fftshift(tfd,2), [], 2);
% tfd=real(tfd); tfd(tfd<0)=0;figure; tfsapl(sig,tfd,'Title','MDD', 'GrayScale','on') 
figure('Name','MDD核');imagesc(abs(g));axis xy; %colormap('hot');axis off;set_gca_style([4,4],'img');
figure('Name','MDD核*IAF');imagesc(abs(am));axis xy; %colormap('hot');axis off;set_gca_style([4,4],'img');
figure('Name','MDD核的TFR');imagesc(abs(tfd1));axis xy; %colormap('hot');axis off;set_gca_style([4,4],'img');

%% 参数不正确的MDD--自定义只增强一个信号的核
% display('half-MDD');
% clear theta tau
% % Input Parameters for MDD     . 
% theta(1)=60;       % Angle one
% tau(1)=0.5;        % parameter to reduce the effect of inner-terms  
% c= 1;              % parameter to adjust the form of shape ... 
% D=0.015;           % parameter to adjust the size of window .. 
% % Calling MDD
% g=proposedkernel(sig, theta,tau,c,D); %MDD kernel.. 
% am=IAF.*g;           % Applying MDD kernel to ambiguity domain function 
% % Code for MDD
% tfd = (fft(ifftshift(am,1), [], 1));
% tfd1=  ifft(fftshift(tfd,2), [], 2);
% % tfd=real(tfd); tfd(tfd<0)=0;figure; tfsapl(sig,tfd,'Title','MDD', 'GrayScale','on') 
% figure('Name','MDD核');imagesc(abs(g));axis xy; colormap('hot');axis off;set_gca_style([4,4],'img');
% figure('Name','MDD核*IAF');imagesc(abs(am));axis xy; colormap('hot');axis off;set_gca_style([4,4],'img');
% figure('Name','MDD核的TFR');imagesc(abs(tfd1));axis xy; colormap('hot');axis off;set_gca_style([4,4],'img');



end

function [amb, tfrep] = wvdClean(x,N)
% Wigner Ville Distribution
%  No windowing or time-resolution variablility
% 输出amb是IAF域结果，tfrep 则是WVD域结果

analytic_sig_ker = signal_kernal(x);
tfrep = real(1./N.*fft(ifftshift(analytic_sig_ker,1), N, 1));
amb = fftshift(1./N.*fft(analytic_sig_ker, N, 2),2);

end


function analytic_sig_ker = signal_kernal(x)
% Matlab programs to develop points learned in the understanding of
% time-frequency distributions
% This is a signal kernel function.
%    Both real and analytic versions.
%   K(n,m) = z(n+m)z*(n-m)
% where, z() is the analytic associate of real input signal s()
%    n is the sampled or discrete time
%    m is the sample or disrete lag
% Nathan Stevenson
% April 2004
%

N = length(x);

if mod(length(x),2) == 0
    true_X = fft(x);
    analytic_X = [true_X(1) 2.*true_X(2:N/2) true_X(N/2+1) zeros(1,N/2-1)];
    analytic_x = ifft(analytic_X);
else
    true_X = fft(x);
    analytic_X = [true_X(1) 2.*true_X(2:ceil(N/2)) zeros(1,floor(N/2))];
    analytic_x = ifft(analytic_X);
end

analytic_sig_ker = zeros(N,N);
for m = -round(N/2-1):1:round(N/2-1);
    analytic_sig_ker(m+round(N/2)+1,:) = sig_ker_corr(analytic_x,m);
end

end


function g=cskabedbelchourini(N,C,D,D1)
% 产生AF域的核函数
x=(-.5+1/N:1/N:.5-1/N);
y=x;
g=zeros(N);
for ii=1:length(x)
    for jj=1:length(y)
        if (x(ii).^2/D.^2+ y(jj).^2/D1^2)<1
            g(ii,jj)=exp(2*C)*exp(C*D^2*(1/(x(ii).^2-D.^2)+1/(y(jj).^2-D1.^2)));
        end
    end
end
g=g/norm(g);
end

function A=proposedkernel(sig,theta,tau,c,D)
%%% Octopus TFD with two angles
%%%% sig : represent signal
%%% theta : vector of angles
%%% c : paramter to adjust the form of shape
%%% D : paramter to adjust the size of window
%%% sigma : paramter to reduce the effect of inner-terms
theta=(theta)*pi/180;
N1=length(sig);N=N1;
y=(-.5+1/N1:1/N1:.5-1/N1);
x=(-.5+1/N:1/N:.5-1/N);
A=zeros(N,N);
for kk=1:length(theta)
    for jj=1:N1-1
        for ii=1:N-1
            x1=cos(theta(kk))*x(ii)-sin(theta(kk))*y(jj);
            y1=sin(theta(kk))*x(ii)+cos(theta(kk))*y(jj);
            z1=(exp(c*(1-exp(abs(x1/D).^2))));
            w=(exp(c*(1-exp(abs(y1/tau(kk)).^2))));
            z1=z1*w;
            if and(x1<D,y1<tau(kk))
            A(ii,jj)=A(ii,jj)+z1;
            end
        end
     end
end
end


function [g_extmb] = extnd_mbd(a,b,min_fre_diff,win_N)

if nargin == 3
    win_N = 128;
end
if nargin == 2
    win_N = 128; min_fre_diff = 0.5;
end

G_mb_Dopper = zeros(win_N,win_N); 
for n = -win_N/2:win_N/2
    G_mb_Dopper(:,mod(n,win_N)+1) = cosh( n ).^( -2 * a );
end
tmp1 = fft(G_mb_Dopper(1,:));
G_mb_Dopper = G_mb_Dopper./tmp1(1);
g_mb_Dopper = real(fft(G_mb_Dopper.').');

G_mb_lag = zeros(win_N,win_N); 
for n = -win_N/2:win_N/2
    G_mb_lag(:,mod(n,win_N)+1) = cosh( n ).^( -2 * b );
end
tmp1 = fft(G_mb_lag(1,:));
G_mb_lag = G_mb_lag./tmp1(1);
g_mb_lag = real(fft(G_mb_lag.').');

effective_win = floor(min_fre_diff*win_N);
g_extmb = g_mb_lag.'.*g_mb_Dopper;
tmp = -win_N/2:win_N/2-1;
g_extmb(:,abs(tmp) <= (win_N/2-effective_win)) = 0;
end


function sig_ker_m = sig_ker_corr(x,m)
% A correlation function to aid in the creation
% of the signal kernel.
% Nathan Stevenson
% SPR June 2004

N = length(x);
z_nmm = [zeros(1,N+m) x zeros(1,N-m)];
z_npm = [zeros(1,N-m) x zeros(1,N+m)];
ker_nm = z_npm.*conj(z_nmm);
sig_ker_m = ker_nm(N+1:2*N);
end

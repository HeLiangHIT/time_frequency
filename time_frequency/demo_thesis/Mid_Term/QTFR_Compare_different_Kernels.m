function QTFR_Compare_different_Kernels
%% script 对比不同QTFR设计核

clear all; clc; close all
N=128;
x = linspace(-0.5,0.5,N);

%% EMBD核
display('EMBD');
g=ifftshift(extnd_mbd(0.8,0.1,0.5,N));
figure;imagesc(x,x,g);axis xy; xlabel('{\itv}');ylabel('\tau');%title('EMBD');
colormap('hot');set_gca_style([6,6]);grid off;

g=ifftshift(extnd_mbd(0.1,0.8,0.5,N));
figure;imagesc(x,x,g);axis xy; xlabel('{\itv}');ylabel('\tau');%title('EMBD');
colormap('hot');set_gca_style([6,6]);grid off;

%% CKD核
display('CKD');
% Defining Parameters
C=10;                              % parameters C controls the shape of kernel
D=0.9;E=0.2;                           % parameters D, E controls the spread of kernel 
g=cskabedbelchourini(N,C,D,E);  % CKD Kernel
figure;imagesc(x,x,g);axis xy; xlabel('{\itv}');ylabel('\tau');%title('EMBD');
colormap('hot');set_gca_style([6,6]);grid off;

C=4;                              % parameters C controls the shape of kernel
D=0.1;E=0.5;                           % parameters D, E controls the spread of kernel 
g=cskabedbelchourini(N,C,D,E);  % CKD Kernel
figure;imagesc(x,x,g);axis xy; xlabel('{\itv}');ylabel('\tau');%title('EMBD');
colormap('hot');set_gca_style([6,6]);grid off;


%% MDD核--这个核很适合用来设计针对多分量LFM信号滤波
display('MDD');
% Input Parameters for MDD     . 
theta=[90,60];       % Angle
tau=[0.5,0.5];        % parameter to reduce the effect of inner-terms  
c= 1;              % parameter to adjust the form of shape ... 
D=0.015;           % parameter to adjust the size of window .. 
% Calling MDD
g=proposedkernel(N, theta,tau,c,D); %MDD kernel.. 
figure;imagesc(x,x,g);axis xy; xlabel('{\itv}');ylabel('\tau');%title('EMBD');
colormap('hot');set_gca_style([6,6]);grid off;

theta=[90,60,30];       % Angle
tau=[0.4,0.9,0.2];        % parameter to reduce the effect of inner-terms  
c= 1;              % parameter to adjust the form of shape ... 
D=0.015;           % parameter to adjust the size of window .. 
% Calling MDD
g=proposedkernel(N, theta,tau,c,D); %MDD kernel.. 
figure;imagesc(x,x,g);axis xy; xlabel('{\itv}');ylabel('\tau');%title('EMBD');
colormap('hot');set_gca_style([6,6]);grid off;


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

function A=proposedkernel(sigN,theta,tau,c,D)
%%% Octopus TFD with two angles
%%%% sigN : samples number of signal 
%%% theta : vector of angles
%%% c : paramter to adjust the form of shape
%%% D : paramter to adjust the size of window
%%% sigma : paramter to reduce the effect of inner-terms
theta=(theta)*pi/180;
N1=sigN;N=N1;
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



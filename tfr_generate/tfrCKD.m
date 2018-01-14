function tfr = tfrCKD(x,N,C,D,D1)
% 计算Compact Kernel distribution：tfr = tfrCKD(x,N,C,D,D1)
% 计算CKD分布，参考： Boashash B, Khan N A, Ben-Jabeur T. Time–frequency features
% for pattern recognition using high-resolution TFDs: A tutorial review
% [J]. Digital Signal Processing, 2015, 40(2015): 1-30.  第2.3节
% 输入：x是输入的一维信号（实数或者复数都行）。其它输入参数是核参数，不明白的看文献决定。
% 输出：tfd是复数矩阵。

x = x(:).';%维数匹配

if nargin < 5
    N = length(x);    C = 1;    D = 0.1;    D1 = 0.06;%核参数
end

g=cskabedbelchourini(N,C,D,D1);%AF域低通滤波核
[am, ~]=wvdClean(x,length(x));
am=am.*g;
tfr = (fft(ifftshift(am,1), [], 1));
tfr=  ifft(fftshift(tfr,2), [], 2);

end

function [amb, tfrep] = wvdClean(x,N)
% Wigner Ville Distribution
%  No windowing or time-resolution variablility

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
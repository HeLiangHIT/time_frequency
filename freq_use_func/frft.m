function y = frft(x, p, N)
% 修正：1）可以自定义变换长度，~2）让其缩放与FFT效果相同~
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fractional Fourier Transform
%	frac_x = fracft(x, theta) with scale of sqrt(length(x))
%	x      : Signal under analysis，信号长度最好为偶数，否则变换不可逆。
%	theta  : Fractional Angle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3; N = length(x); end

x = [x(:); zeros(N-length(x),1)];
y = fracft(x,p);
% y = frft_org(x,p);
y = y * sqrt(N);%缩放恢复
y = fftshift(y);%位移恢复
% M = floor(N/2);
% y = [y(M+1:N); y(1:M)];

end


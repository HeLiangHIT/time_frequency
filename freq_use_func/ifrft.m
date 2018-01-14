function y = ifrft(x, p, N)
% 修正：1）可以自定义变换长度，~2）让其缩放与FFT效果相同~
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inverse Fractional Fourier Transform
%	y = ifrft(x, p, N)
%	x  : Signal under analysis，信号长度最好为偶数，否则变换不可逆。
%	p  : Fractional Angle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 3; N = length(x); end

x = x / sqrt(N);%缩放恢复
x = fftshift(x);%位移恢复
% y = frft_org(x,-p);
y = fracft(x,-p);
y = y(1:N);

end

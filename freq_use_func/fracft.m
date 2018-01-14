function frac_x = fracft(x, theta)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fractional Fourier Transform
%	frac_x = fracft(x, theta) with scale of sqrt(length(x))
% 
%	x      : Signal under analysis
%	theta  : Fractional Angle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Main Program
N = length(x); M = floor(N/2);
theta = mod(theta,4);
if (theta==0)
  frac_x = x;
  return
elseif (theta==1)
  frac_x = fft([x(M+1:N); x(1:M)])/sqrt(N);
  frac_x = [frac_x(M+2:N); frac_x(1:M+1)]; % [[[--a sample delay related to fft--]]]
  return
elseif (theta==2)
  frac_x = flipud(x);
  return
elseif (theta==3)
  frac_x = ifft([x(M+1:N); x(1:M)])*sqrt(N);
  frac_x = [frac_x(M+2:N); frac_x(1:M+1)];
  return
end
if (theta > 2)
  x = flipud(x);
  theta = theta - 2;
end
if (theta > 1.5)
  x = fft([x(M+1:N); x(1:M)])/sqrt(N);
  x = [x(M+2:N); x(1:M+1)];
  theta = theta - 1;
end
if (theta < 0.5)
  x = ifft([x(M+1:N); x(1:M)])*sqrt(N);
  x = [x(M+2:N); x(1:M+1)];
  theta = theta + 1;
end

%% Interpolation using Sinc
P = 3;
x = interp_sinc(x, P);
x = [zeros(2*M,1) ; x ; zeros(2*M,1)];

%% Axis Shearing
phi   = theta*pi/2;
alpha = cot(phi);
beta  = csc(phi);
%%% First: Frequency Shear
c = 2*pi/N*(alpha-beta)/P^2;
NN = length(x); MM = (NN-1)/2; n = (-MM:MM)';
x2 = x.*exp(1i*c/2*n.^2);
% %%% Second: Time Shear
c = 2*pi/N*beta/P^2;
NN = length(x2); MM = (NN-1)/2;
interp = ceil(2*abs(c)/(2*pi/NN));
xx = interp_sinc(x2,interp)/interp;
n = (-2*MM:1/interp:2*MM)';
h = exp(1i*c/2*n.^2);
x3 = conv(xx, h, 'same');
if (isreal(xx) && isreal(h)); x3 = real(x3); end
center = (length(x3)+1)/2;
x3 = x3(center-interp*MM:interp:center+interp*MM);
x3 = x3*sqrt(c/2/pi);
%%% Third: Frequency Shear
c =  2*pi/N*(alpha-beta)/P^2;
NN = length(x3); MM = (NN-1)/2; n = (-MM:MM)';
frac_x = x3.*exp(1i*c/2*n.^2);

%% Output Signal
frac_x = frac_x(2*M+1:end-2*M);
frac_x = frac_x(1:P:end);
frac_x = exp(-1i*(pi*sign(sin(phi))/4-phi/2))*frac_x;



end

function x_r = interp_sinc(x, a)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Interpolation using anti-aliasing filter (Sinc Interpolation)
% x_r = interp_sinc(x, a)
% 
% x      : Signal under analysis
% a      : Resample ratio, equivalent to P/Q in the built in function
%         "resample"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%
N = length(x);       % Original number samples
M = a*N - a + 1;     % New number of samples
temp1 = zeros(M,1);  %
temp1(1:a:M) = x;    % Adding a-1 zeros between samples

%% Creating the Sinc function
n = -(N-1-1/a):1/a:(N-1-1/a); h = sinc(n(:));

%% Filtering in the Frequency Domain
x_r = conv(temp1, h, 'same');
if (isreal(temp1) && isreal(h)); x_r = real(x_r); end
end
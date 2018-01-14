function Compare_Separable_kernels
%% script  对比和演示可分离核的原理，这里只能演示结果无法演示计算的中间过程。
% 不用尝试增加演示中间结果，费事不讨好。
% Test separable kernels.

%% 第一种信号对比
clear all; clc; close all;
% TONE(frequency 0.1 Hz) and a LFM signal (frequency range 0.2-0.4 Hz)参数
M=64;		% no. samples - 1
A=1;		% amplitude
fc=0.1;	% carrier freq.
f0=0.2;	% starting freq.
B=0.2;	% freq. range
alpha=B/M;	% sweep rate

N = 2*M;	% padded FFT length

% 产生实数信号
t = 0:M;
s = A*cos(2*pi*fc*t) + A*cos(2*pi*((f0+(alpha/2)*t).*t));

% 计算普通 WVD
wv=tlkern(s,N);
figure;tfsapl(abs(s),wv,'Timeplot','on','Freqplot','on','Grayscale','on', 'title', 'WVD');
% 计算时间方向采用hann窗的滤波后信号
tfd=tlkern(s,N,1,'hann',15);%LI, time Hann 15
figure;tfsapl(real(s),tfd,'Timeplot','on','Freqplot','on','Grayscale','on', 'title', 'LI, time Hann 15'); 

pause
%% 第二种信号对比
clear all; close all; clc;
% 信号产生 tone (frequency 0.15 Hz) +LFM signal (0.35-0.4 Hz)
M=64;		% no. samples - 1
A=1;		% amplitude
fc=0.15;	% carrier freq.
fm=2/M;	% modulating freq.
f0=0.35;	% starting freq.
B=0.05;	% freq. range
alpha=B/M;	% sweep rate

N = 2*M;	% padded FFT length

% 信号产生
t = 0:M;
s = A*cos(2*pi*fc*t) + A*cos(2*pi*((f0+(alpha/2)*t).*t));

% 计算WVD
tfd=tlkern(s,N);
figure;tfsapl(real(s),tfd,'Timeplot','on','Freqplot','on','Grayscale','on', 'title' ,'WVD'); 
% 计算时延轴采用hamm的滤波后谱
tfd=tlkern(s,N,1,'delta',1,'hamm',47);
figure;tfsapl(real(s),tfd,'Timeplot','on','Freqplot','on','Grayscale','on', 'title', 'WVD, lag Hamm 47'); 

% LI, time Hann 11
tfd=tlkern(s,N,1,'hann',11);
figure;tfsapl(real(s),tfd,'Timeplot','on','Freqplot','on','Grayscale','on', 'title', 'LI, time Hann 11'); 

% Separable, time hann 11, lag Hamm 47
tfd=tlkern(s,N,1,'hann',11,'hamm',47);
figure;tfsapl(real(s),tfd,'Timeplot','on','Freqplot','on','Grayscale','on', 'title','Separable, time hann 11, lag Hamm 47'); 

% MB alpha = 0.2
tfd=tlkern(s,N,1,'delta',1,'1',1,'mb',0.2);
figure;tfsapl(real(s),tfd,'Timeplot','on','Freqplot','on','Grayscale','on', 'title','MB 0.2');

% Spectrogram, rect 35
tfd=tlkern(s,N,1,'delta',1,'rect',35,'sg');
figure; tfsapl(real(s),tfd,'Timeplot','on','Freqplot','on','Grayscale','on', 'title','Spectrogram, rect 35');

pause
%% 第三种信号对比
close all; 
% FM signal (frequency 0.15 ?0.05 Hz)+LFM signal (frequency range 0.35-0.4 Hz)
fd=3.2/M;	% freq. deviation
n = 0:M;
s = A*cos(2*pi*fc*n+(fd/fm)*cos(2*pi*fm*n)) + A*cos(2*pi*((f0+(alpha/2)*n).*n));

tfd=tlkern(s,N);
figure; tfsapl(real(s),tfd,'Timeplot','on','Freqplot','on','Grayscale','on', 'title','WVD');

% WVD, lag Hamm 23
tfd=tlkern(s,N,1,'delta',1,'hamm',23);   %Doppler Independent
figure; tfsapl(real(s),tfd,'Timeplot','on','Freqplot','on','Grayscale','on', 'title','WVD, lag Hamm 23');

% LI, time Hann 11
tfd=tlkern(s,N,1,'hann',11);       %Lag Independent
figure; tfsapl(real(s),tfd,'Timeplot','on','Freqplot','on','Grayscale','on', 'title', 'LI, time Hann 11');

% Separable, time hann 11, lag Hamm 23
tfd=tlkern(s,N,1,'hann',11,'hamm',23); %Separable Fig 5.7.3(d).
figure; tfsapl(real(s),tfd,'Timeplot','on','Freqplot','on','Grayscale','on', 'title', 'Separable, time hann 11, lag Hamm 23');

% CW 1
tfd=tlkern(s,N,1,'delta',1,'1',1,'cw',1); %Exponential Distribution
figure; tfsapl(real(s),tfd,'Timeplot','on','Freqplot','on','Grayscale','on', 'title','CW 1');

% Spectrogram, rect 17
tfd=tlkern(s,N,1,'delta',1,'rect',17,'sg');  %Spectrogram
figure; tfsapl(real(s),tfd,'Timeplot','on','Freqplot','on','Grayscale','on', 'title','Spectrogram, rect 17');



end

function [tfd] = tlkern(s,N,tr,tf,L,lf,M,af,ap)
%% 可分离核的QTFD产生，可以指定时间、时延轴的滤波函数以及辅助的函数：
% Quadratic TFD with time-lag kernel.
% The spectrogram is handled separately.  Otherwise the
% kernel is specified by a ``time factor'' (function of time),
% a ``lag factor'' (function of lag) and an ``auxiliary factor''
% (function of time and possibly lag).  The final kernel is
%   (lag factor) . (time factor) * (auxiliary factor)
% where '*' denotes convolution over time.
% (Code attempting to treat the spectrogram as a quadratic TFD
% by assigning the entire kernel to the auxiliary factor
% has been commented out.)
%
% REQUIRED INPUTS:
%   s  = real/complex signal vector
%   N  = assumed signal period (in samples)
%
% To avoid wrap-around, choose
%   N >= length(s) + (time extent of kernel) - 1.
% For efficiency, make N highly composite if TFD requires
% convolution in time.
%
% OPTIONAL INPUTS:
%   tr = time resolution (+ve integer; default = 1)
%   tf = time factor type
%      = ['delta' (default)|'rect'|'hamm'|'hann'|'gauss']
%   L  = length of time factor (in samples):
%        = total extent for tf = ['rect'|'hamm'|'hann']
%        = 8 * sigma    for tf = 'gauss'
%        = 1            for tf = 'delta' (set internally)
%   lf = [ lag factor type | spectrogram window type ]
%      = ['1' (default)|'rect'|'hamm'|'hann'|'gauss']
%   M  = lag length of kernel (in samples):
%        = total extent for lf = ['rect'|'hamm'|'hann']
%        = 8 * sigma    for lf = 'gauss'
%        = length(s)    for lf = '1'     (set internally)
%   af = auxiliary factor type
%      = ['delta' (default)|'mh'|'bj'|'mb'|'zam'|'pg'|'cw'|'b'|'sg']
%   ap = auxiliary parameter
%      = [X (= ignored)|X|alpha|beta|a|X|sigma|beta|X] respectively
%        (see below for defaults)
%
% OUTPUT:
%   tfd(1:Mpad,1:Nsel) = real TFD matrix
% where ...
%   Mpad = 2^ceil(log(2*M)/log(2));  % lag-to-frequency FFT length
%   Ncut = min(N,length(s));         % duration of TF plot
%   Nsel = ceil(Ncut/tr);            % no. traces in TF plot

%% DEFAULT PARAMETERS FOR tlkern(s,N,tr,tf,L,lf,M,af,ap):
if nargin < 2
    error('Not enough parameters.');
end
if nargin < 3
    tr = 1;
end
if nargin < 4
    tf = 'delta';
end
if nargin < 5 || strcmp(tf,'delta')
    L = 1;
end
if nargin < 6
    lf = '1';
end
if nargin < 7 || strcmp(lf,'1')
    M = length(s);
end
if nargin < 8
    af = 'delta';
end
if nargin < 9
    switch af
        case 'bj'
            ap = 0.5;   % default alpha for Born-Jordan
        case 'mb'
            ap = 0.01;  % default beta  for Modified B
        case 'zam'
            ap = 2;     % default a     for Zhao-Atlas-Marks
        case 'cw'
            ap = 1;     % default sigma for Choi-Williams
        case 'b'
            ap = 0.01;  % default beta  for B distribution
        otherwise
            % ap ignored
    end
end
if nargin > 9
    error('Too many parameters.');
end

%% CHECK FOR ERRORS IN CALL tlkern(s,N,tr,tf,L,lf,M,af,ap):
if N <= 0
    error('Signal period must be positive.');
end
if tr <= 0
    error('Time resolution must be positive.');
end
if M <= 0
    error('Lag extent of kernel must be positive.');
end
if M > N
    error('Lag extent of kernel must not exceed signal period.');
end

%% SET DIMENSIONS:
Mpad = 2^ceil(log(2*M)/log(2));  % lag-to-frequency FFT length
Ncut = min(N,length(s));         % duration of TF plot
Nsel = ceil(Ncut/tr);            % no. traces in TF plot

%% COMPUTE ANALYTIC ASSOCIATE OF s, DENOTED BY z:
clear z;
Noff = fix(N/2);
z = fft(real(s),N);           % s truncated or padded
z(2:N-Noff) = 2*z(2:N-Noff);  % positive frequencies
z(Noff+2:N) = 0;              % negative frequencies
z = ifft(z);
% N.B.: Time-limited s does not imply time-limited z.

%% COMPUTE TIME FACTOR g1 (WITH FFT SHIFT):
clear g1;
Loff = fix(L/2);
g1(1:N) = 0;
switch tf
    case 'delta'
        g1(1) = 1;
    case 'rect'
        for l = -Loff:Loff
            g1(1+rem(N+l,N)) = 1;
        end
        g1 = g1/sum(g1); % normalize
    case 'hamm'
        for l = -Loff:Loff
            g1(1+rem(N+l,N)) = 0.54+0.46*cos(2*pi*l/L);
        end
        g1 = g1/sum(g1); % normalize
    case 'hann'
        for l = -Loff:Loff
            g1(1+rem(N+l,N)) = 0.5+0.5*cos(2*pi*l/L);
        end
        g1 = g1/sum(g1); % normalize
    case 'gauss'
        for l = -Loff:Loff
            g1(1+rem(N+l,N)) = exp(-0.5*(8*l/L)^2);
        end
        g1 = g1/sum(g1); % normalize
    otherwise
        error('Invalid time factor in tlkern.');
end
if rem(L,2) == 0 % end correction:
    g1(1+Loff) = g1(1+Loff)/2;
    g1(1+N-Loff) = g1(1+N-Loff)/2;
end

%% COMPUTE LAG FACTOR g2 (WITH FFT SHIFT):
clear g2;
Moff = fix(M/2);
g2(1:Mpad) = 0;
switch lf
    case '1'
        g2(1:Mpad) = 1;
    case 'rect'
        for m = -Moff:Moff
            g2(1+rem(Mpad+m,Mpad)) = 1;
        end
    case 'hamm'
        for m = -Moff:Moff
            g2(1+rem(Mpad+m,Mpad)) = 0.54+0.46*cos(2*pi*m/M);
        end
    case 'hann'
        for m = -Moff:Moff
            g2(1+rem(Mpad+m,Mpad)) = 0.5+0.5*cos(2*pi*m/M);
        end
    case 'gauss'
        for m = -Moff:Moff
            g2(1+rem(Mpad+m,Mpad)) = exp(-0.5*(8*m/M)^2);
        end
    otherwise
        error('Invalid lag factor in tlkern.');
end
if rem(M,2) == 0 % end correction:
    g2(1+Moff) = g2(1+Moff)/2;
    g2(1+Mpad-Moff) = g2(1+Mpad-Moff)/2;
end

%% COMPUTE AUXILIARY FACTOR AND STORE IN g3:
clear g3 temp temp1 temp2;
g3(1:N,1:Mpad) = 0;
switch af
    case 'sg'
        % handled separately
        %     for n = -Moff:Moff
        %       for m = -Moff:Moff
        %         % g3(n,m) = g2(n+m)g2(n-m), with corrected indices:
        %         g3(1+rem(N+n,N),1+rem(Mpad+m,Mpad)) ...
        %         = g2(1+rem(Mpad+m,Mpad))*g2(1+rem(Mpad-m,Mpad));
        %       end
        %     end
        %     g3 = g3/(2*Moff+1);
    case 'delta'
        % handled separately
    case 'mh'
        for m = -Moff:Moff
            g3(1+rem(N+m,N),1+rem(Mpad+m,Mpad)) = 0.5;
            g3(1+rem(N+m,N),1+rem(Mpad-m,Mpad)) = 0.5;
        end
        g3(1,1) = 1;
    case 'bj'
        for n = -Noff:Noff
            for m = -Moff:Moff
                temp1 = abs(4*ap*m)+1;
                if abs(2*n) <= temp1;
                    g3(1+rem(N+n,N),1+rem(Mpad+m,Mpad)) = 1/temp1;
                end
            end
        end
    case 'mb'
        temp(1:N) = 0;
        for n = -Noff:Noff
            temp(1+rem(N+n,N)) = (cosh(n))^(-2*ap);
        end
        temp = temp/sum(temp); % normalize
        for m = -Moff:Moff
            g3(:,1+rem(Mpad+m,Mpad)) = temp.';
        end
    case 'zam'
        for n = -Noff:Noff
            for m = -Moff:Moff
                if abs(ap*n) <= abs(2*m);
                    g3(1+rem(N+n,N),1+rem(Mpad+m,Mpad)) = 1;
                    % Lag factor comes from g2, specified above.
                end
            end
        end
    case 'pg'
        for m = 0:Moff
            g3(1+rem(N+m,N),1+rem(Mpad+m,Mpad)) = 1;
            g3(1+rem(N+m,N),1+rem(Mpad-m,Mpad)) = 1;
        end
    case 'cw'
        g3(1,1) = 1;
        for m = 1:Moff
            temp1 = sqrt(1/(4*m*m/pi/ap+1));
            for n = 0:Noff
                temp2 = temp1*exp(-pi*pi*ap*n*n/(4*m*m+pi*ap));
                g3(1+rem(N+n,N),1+rem(Mpad+m,Mpad)) = temp2;
                g3(1+rem(N+n,N),1+rem(Mpad-m,Mpad)) = temp2;
                g3(1+rem(N-n,N),1+rem(Mpad+m,Mpad)) = temp2;
                g3(1+rem(N-n,N),1+rem(Mpad-m,Mpad)) = temp2;
            end
        end
    case 'b'
        for m = -Moff:Moff
            temp(1+rem(Mpad+m,Mpad)) = (4*m*m+1)^(ap/2);
        end
        for n = -Noff:Noff
            temp2(1+rem(N+n,N)) = (cosh(n))^(-2*ap);
        end
        g3 = temp2.'*temp/sum(temp2);
    otherwise
        error('Invalid auxiliary factor in tlkern.');
end

%% SET UP INSTANTANEOUS AUTOCORRELATION FUNCTION (IAF):
clear K;
K = zeros(N,Mpad);
if strcmp(af,'sg') % spectrogram (K is not really IAF):
    for n = 1:N
        for m = -Moff:Moff
            % K(n,m) = z(n+m)g2(m), with corrected indices:
            K(n,1+rem(Mpad+m,Mpad)) = z(1+rem(2*N+n+m-1,N))*g2(1+rem(Mpad+m,Mpad));
        end
    end
else % other distributions (K is really IAF):
    for n = 1:N
        for m = -Moff:Moff
            % K(n,m) = z(n+m)z^*(n-m), with corrected indices:
            K(n,1+rem(Mpad+m,Mpad)) = z(1+rem(2*N+n+m-1,N))*conj(z(1+rem(2*N+n-m-1,N)));
        end
    end
end

%% CONVOLVE IAF IN TIME WITH KERNEL (MODULO-N):
clear mcorr;
for m = -Moff:Moff
    % Prepare mth column of kernel:
    mcorr = 1+rem(Mpad+m,Mpad);
    if strcmp(af,'sg') % spectrogram
        % handled separately
        %     K(:,mcorr) = ifft(fft(K(:,mcorr)).*fft(g3(:,mcorr)));
    elseif strcmp(af,'delta') % separable
        if strcmp(tf,'delta') % WVD or windowed WVD
            K(:,mcorr) = K(:,mcorr)*g2(mcorr);
        else % non-trivial separable
            K(:,mcorr) = ifft(fft(K(:,mcorr)).*fft(g1.'*g2(mcorr)));
        end
    else % general
        K(:,mcorr) = ifft(fft(K(:,mcorr)).*fft(g3(:,mcorr)).*fft(g1.'*g2(mcorr)));%和辅助函数卷积
    end
end

%% BUILD GENERALIZED IAF WITH SPECIFIED TIME RESOLUTION:
clear r;
r = zeros(Mpad,Nsel);
for nsel = 1:Nsel
    % nselth column of r is selected row of K:
    n = 1+tr*(nsel-1);
    r(:,nsel) = K(n,:).';
end

%% COMPUTE TFD, NORMALIZED FOR CORRECT TOTAL ENERGY OF ANALYTIC SIGNAL:
clear tfd;
r = fft(r);
if strcmp(af,'sg') % spectrogram
    tfd = (abs(r(1:Mpad/2+1,:))).^2.*(Ncut/Nsel/Mpad/sum(g2.^2));
else
    tfd = [real(r);real(r(1,:))].*(Ncut/Nsel/Mpad);
end
end


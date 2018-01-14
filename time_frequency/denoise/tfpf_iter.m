function [y,tfr] = tfpf_iter(s, maxf, FreqLen)
%% per iter of time-frequency peak filtering
% reference : Boashash B, Mesbah M. Signal enhancement by time-frequency peak filtering [J]. IEEE Transactions on Signal Processing, 2004, 52(4): 929-37.
% and : Rankine L, Mesbah M, Boashash B. IF estimation for multicomponent signals using image processing techniques in the time¨Cfrequency domain [J]. Signal Process, 2007, 87(6): 1234-50.
% requires: Time-Frequency Toolbox for tfrpwv.m
% input :
% s : input real signal
% maxf : input maximum IF(say fmax/Fs and assume Fs=1), closely related to
% lag window length.

if nargin < 2; maxf = 0.5; end
if nargin < 3; FreqLen = 512; end

s = s(:);% limited to one column
%% parameter init
WinLen = floor(1.28*1/pi/maxf) - 1;%lag window length, ref eq[]
WinLen = WinLen + (~mod(WinLen,2));%limited to odd 
if WinLen<3; WinLen = 3; end
GuardEdge = WinLen * 2;%safe guard edge len

Miu = 0.9;
h=ones(WinLen,1);%rect window
guard = ones(GuardEdge,1);%safe guard edge

%% generate z(t)
sr = [guard*s(1);s;guard*s(end)];
maxValue = max(sr(:));
minValue = min(sr(:));
x = (sr - minValue)/(maxValue-minValue)*0.3+0.1;%limited signal to 0.1-0.4
sc = cumsum(x);%plot(sc)
z = exp(1j * 2 * pi * Miu * sc);

%% PWVD peak if est...
[tfr,~,~]=tfrpwv(z,1:length(z),FreqLen,h);
% subplot(4,1,1:3);imagesc(tfr); subplot(4,1,4);plot(sr); axis tight
[~,flaw]=max(tfr);
flaw = flaw/FreqLen/2;%normalization
ye = (flaw/Miu - 0.1) * (maxValue-minValue)/0.3 + minValue;%inverse transformation

y = ye((GuardEdge+1):(end - GuardEdge));
tfr = tfr(:,(GuardEdge+1):(end - GuardEdge));
% t = 1:length(s); plot(t,s,'bx-',t,y,'r.-');

end
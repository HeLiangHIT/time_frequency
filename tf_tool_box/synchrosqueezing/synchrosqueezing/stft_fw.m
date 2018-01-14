function [Sx,tau,fs] = stft_fw(t, x, opt)
% STFT  Compute the short-time Fourier transform
%
% Very closely based on Steven Schimmel's stft.m and istft.m from
% his SPHSC 503: Speech Signal Processing course at Univ. Washington.

if nargin<3, opt = struct(); end

if ~isfield(opt, 'window'), opt.window = round(length(x)/16); end
if length(opt.window) == 1, opt.window = hamming(opt.window); end
%if ~isfield(opt, 'overlap'), opt.overlap = length(opt.window)-1; end
opt.overlap = length(opt.window)-1;

window = opt.window / norm(opt.window, 2); % Unit norm

% Pre-pad signal
n = length(x);

% extract short-time segments from the input
Nwin = length(window);
xbuf = buffer(x, Nwin, opt.overlap, 'nodelay');

% apply the specified window
xbuf = diag(sparse(window)) * xbuf;

% take the FFT, and keep only 0 to pi
Sx = fft(xbuf,[],1);
Sx = Sx(1:floor(Nwin/2)+1, :);

% define time and frequency sampling vectors
tau = [0:size(Sx,2)-1]*(Nwin-opt.overlap) + (Nwin-1)/2;
fs = linspace(0,1,Nwin+1); fs = fs(1:floor(Nwin/2)+1);

% correct for sampling frequency
tdiff = median(diff(t));
tau = tau * tdiff;
fs = fs / tdiff;

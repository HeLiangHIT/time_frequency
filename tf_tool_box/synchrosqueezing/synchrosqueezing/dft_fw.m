% function [Fx, fs] = dft_fw(t, x, opt)
%
% Fourier transform of signal and associated frequencies.
% If the signal length is not a power of 2, this function first
% pads x to the next higher power using options in opt.
%
% Input:
%  t: time vector (assumed regularly sampled)
%  x: signal vector
%  opt: options structure
%    opt.padtype: type of padding (see help padarray); default: 'symmetric'
%
% Output:
%  Fx: DFT of x
%  fs: associated frequencies, based on vector t
%
% Note: if you wish to accurately plot abs(Fx) vs. fs,
% multiply by Fx by 2*pi to regain the magnitudes of the original
% signals.
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function [Fx, fs] = dft_fw(t, x, opt)
if nargin<3, opt = struct(); end

if ~isfield(opt, 'padtype'), opt.padtype = 'symmetric'; end

n = length(x);
[xpad,nup] = padsignal(x, opt.padtype);

Fxpad = fft(xpad);
Fx = 1/(pi*nup)*Fxpad(2:nup/2);

fs = 1/(median(diff(t))*nup)*[1:nup/2-1];
end

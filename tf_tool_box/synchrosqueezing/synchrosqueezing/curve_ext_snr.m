% snrp = curve_ext_snr(x, Tx, fs, Cs, Es, opt, clwin)
%
% Estimate the SNR of the signal: first having extracted individual
% curves from the signal, these are treated as the "signal"
% component.  The remainder of the signal is treated as noise.
%
% Inputs:
%  x: original signal
%  Tx, fs: output of synsq_cwt_fw
%  Cs, Es: output of curve_ext_multi
%  opt: options struct for curve_ext_recon (see help curve_ext_recon)
%  clwin: input to curve_ext_recon
%
% Output:
%  snrp: SNR estimate.  To get in dB, use 10*log10(snrp)
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function snrp = curve_ext_snr(x, Tx, fs, Cs, Es, opt, clwin)

if nargin<7, clwin = 4; end
if nargin<6, opt = struct(); end

Nc = length(Es);
[na, N] = size(Tx);

assert(N == length(x));

% Reconstruct the curve signals
xrs = curve_ext_recon(Tx, fs, Cs, opt, clwin);

% Sum up the curves to get the "true" signal
xp = sum(xrs, 2)';

% Estimate the noise
np = x - xp;

% SNR estimate
snrp = sum(xp.^2)/sum(np.^2);

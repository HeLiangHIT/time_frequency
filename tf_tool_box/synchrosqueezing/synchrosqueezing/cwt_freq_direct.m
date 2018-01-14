% function w = cwt_freq_direct(Wx, dWx, opt)
%
% Calculate the demodulated FM-frequency at each (scale,time) pair:
%   w(a,b) = Im( (1/2pi) * d/db [ Wx(a,b) ] / Wx(a,b) )
% Uses direct differentiation by calculating dWx/db in frequency
% domain (the secondary output of cwt_fw, see help cwt_fw)
%
% This is the analytic implementation of Eq. (7) of [1].
%
% 1. E. Brevdo, N.S. Fučkar, G. Thakur, and H-T. Wu, "The
% Synchrosqueezing algorithm: a robust analysis tool for signals
% with time-varying spectrum," 2011.
%
%
% Input:
%  Wx: wavelet transform of x (see help cwt_fw)
%  dWx: samples of time derivative of wavelet transform of x (see help cwt_fw)
%  opt: options struct,
%    opt.gamma: wavelet threshold (default: sqrt(machine epsilon))
%
% Output:
%  w: demodulated FM-estimates, size(w) = size(Wx)
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function w = cwt_freq_direct(Wx, dWx, opt)
    if nargin<3, opt = struct(); end
    % epsilon from Daubechies, H-T Wu, et al.
    % gamma from Brevdo, H-T Wu, et al.
    if ~isfield(opt, 'gamma'); opt.gamma = sqrt(eps); end

    % Calculate inst. freq for each ai, normalize by (2*pi) for
    % true freq.
    w = imag(dWx ./ Wx / (2*pi));
    w((abs(Wx)<opt.gamma))=NaN;
end

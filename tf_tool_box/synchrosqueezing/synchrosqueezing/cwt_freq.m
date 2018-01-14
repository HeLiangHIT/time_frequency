% function w = cwt_freq(Wx, dt, opt)
%
% Calculate the demodulated FM-frequency at each (scale,time) pair:
%   w(a,b) = Im( (1/2pi) * d/db [ Wx(a,b) ] / Wx(a,b) )
% Uses numerical differentiation (1st, 2nd, or 4th order).
%
% This is a numerical differentiation implementation of Eq. (7) of
% [1].
%
% 1. E. Brevdo, N.S. Fučkar, G. Thakur, and H-T. Wu, "The
% Synchrosqueezing algorithm: a robust analysis tool for signals
% with time-varying spectrum," 2011.

% Input:
%  Wx: wavelet transform of x (see help cwt_fw)
%  dt: delta t, the sampling period (e.g. t(2)-t(1))
%  opt: options struct,
%    opt.dorder: differences order (values: 1, 2, 4.  default = 4)
%    opt.gamma: wavelet threshold (default: sqrt(machine epsilon))
%
% Output:
%  w: demodulated FM-estimates, size(w) = size(Wx)
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function w = cwt_freq(Wx, dt, opt)
  if nargin<3, opt = struct(); end
  % Order of differentiation (1, 2, or 4)
  if ~isfield(opt, 'dorder'), opt.dorder = 4; end
  % epsilon from Daubechies, H-T Wu, et al.
  % gamma from Brevdo, H-T Wu, et al.
  if ~isfield(opt, 'gamma'); opt.gamma = sqrt(eps); end

  % Section below replaced by the following mex code
  w = diff_mex(Wx, dt, opt.dorder);

  % switch opt.dorder
  %   case 1
  %     w = [Wx(:, 2:end) - Wx(:, 1:end-1), ...
  %          Wx(:, 1)-Wx(:, end)];
  %     w = w / dt;
  %   case 2
  %     % Append for differencing
  %     Wxr = [Wx(:, end-1:end) Wx Wx(:, 1:2)];
  %     % Calculate 2nd order forward difference
  %     w = -Wxr(:, 5:end) + 4*Wxr(:, 4:end-1) - 3*Wxr(:, 3:end-2);
  %     w = w / (2*dt);
  %   case 4
  %     % Centered difference with fourth order error
  %     % Append for differencing
  %     Wxr = [Wx(:, end-1:end) Wx Wx(:, 1:2)];

  %     % Calculate 4th order central difference
  %     w = -Wxr(:, 5:end);
  %     w = w + 8*Wxr(:, 4:end-1);
  %     w = w - 8*Wxr(:, 2:end-3);
  %     w = w + Wxr(:, 1:end-4);
  %     w = w / (12*dt);
  %   otherwise
  %     error('Differentiation order %d not supported', opt.dorder);
  % end

  w((abs(Wx)<opt.gamma))=NaN;
  % Calculate inst. freq for each ai, normalize by (2*pi) for
  % true freq.

  w = real(-1i * w ./ Wx) / (2*pi);
end


% function [Tx, fs, Wx, as, w] = synsq_cwt_fw(t, x, nv, opt)
% Quick alternatives:
%    [Tx, fs] = synsq_cwt_fw(t, x, nv)
%    [Tx, fs, Wx, as] = synsq_cwt_fw(t, x, nv)
%    [Tx, fs, Wx, as, w] = synsq_cwt_fw(t, x, nv)
%
% Calculates the synchrosqueezing transform of vector x, with
% samples taken at times given in vector t.  Uses nv voices.  opt
% is a struct of options for the way synchrosqueezing is done, the
% type of wavelet used, and the wavelet parameters.  This
% implements the algorithm described in Sec. III of [1].
%
% 1. E. Brevdo, N.S. Fučkar, G. Thakur, and H-T. Wu, "The
% Synchrosqueezing algorithm: a robust analysis tool for signals
% with time-varying spectrum," 2011.
%
% Input:
%  t: vector of times samples are taken (e.g. linspace(0,1,n))
%  x: vector of signal samples (e.g. x = cos(20*pi*t))
%  nv: number of voices (default: 16, recommended: 32 or 64)
%  opt: struct of options
%    opt.type: type of wavelet (see help wfiltfn)
%      opt.s, opt.mu, etc (wavelet parameters: see opt from help wfiltfn)
%    opt.disp: display debug information?
%    opt.gamma: wavelet hard thresholding value (see help cwt_freq_direct)
%    opt.dtype: direct or numerical differentiation (default: 1,
%               uses direct).  if dtype=0, uses MEX differentiation
%               instead (see help cwt_freq), which is faster and
%               uses less memory, but may be less accurate.
%    
% Output:
%  Tx: synchrosqueezed output of x (columns associated with time t)
%  fs: frequencies associated with rows of Tx
%  Wx: wavelet transform of x (see cwt_fw)
%  as: scales associated with rows of Wx
%  w: instantaneous frequency estimates for each element of Wx
%     (see help cwt_freq_direct)
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function [Tx, fs, Wx, as, w] = synsq_cwt_fw(t, x, nv, opt)

if nargin<4, opt = struct(); end
if nargin<3, nv = 16; end
if nargin<2, error('Too few input arguments'); end

% Choose some default values
% Wavelet type
if ~isfield(opt, 'type'), opt.type = 'morlet'; end
% Display bugging information?
if ~isfield(opt, 'disp'), opt.disp = 0; end
% Direct or numerical differntiation? (default: direct)
if ~isfield(opt, 'dtype'), opt.dtype = 1; end

% Calculate sampling period, assuming regular spacing
dt = t(2)-t(1);

% Check for uniformity of spacing
if any(diff(t,2)/(t(end)-t(1))>1e-5)
    error('time vector t is not uniformly sampled');
end


% Calculate the wavelet transform - padded via symmetrization
x = x(:);
N = length(x);
[Nup,n1,n2] = p2up(N);

if (opt.dtype)
    % Calculate derivative directly in the wavelet domain before taking
    % wavelet transform.

    % Don't return padded data
    opt.rpadded = 0;

    [Wx,as,dWx] = cwt_fw(x, opt.type, nv, dt, opt);

    % Approximate instantaneous frequency
    w = cwt_freq_direct(Wx, dWx, opt);

    clear dWx;
else
    % Calculate derivative numerically after calculating wavelet
    % transorm.  This requires less memory and is more accurate at
    % small a.

    % Return padded data
    opt.rpadded = 1;

    [Wx,as] = cwt_fw(x, opt.type, nv, dt, opt);
    Wx = Wx(:, n1-4+1:n1+N+4);

    % Approximate instantaneous frequency
    w = cwt_freq(Wx, dt, opt);
end

% Calculate the synchrosqueezed frequency decomposition
[Tx,fs] = synsq_cwt_squeeze(Wx, w, t, nv, opt);

if ~opt.dtype
    Wx = Wx(:, 4+1:end-4);
    w = w(:, 4+1:end-4);
    Tx = Tx(:, 4+1:end-4);
end

end

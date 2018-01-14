%
% function [Tx,fs] = synsq_cwt_squeeze(Wx, w, t, nv, opt)
%
% Calculates synchrosqueezed transform of f on a logarithmic
% scale.  Used internally by synsq_cwt_fw.
%
% Input:
%   Wx: wavelet transform of x
%   w: estimate of frequency at locations in Wx (see synsq_cwt_fw code)
%   t: time vector
%   nv: number of voices
%   opt: options struct, not currently used
%
% Output:
%   Tx: synchrosqueezed output
%   fs: associated frequencies
%
% Note the multiplicative correction term f in synsq_cwt_squeeze_mex (and in
% the matlab equivalent code commented out), required due to the fact that
% the squeezing integral of Eq. (2.7), in, [1], is taken w.r.t. dlog(a).
% This correction term needs to be included as a factor of Eq. (2.3), which
% we implement here.
%
% A more detailed explanation is available in Sec. III of [2].
% Specifically, this is an implementation of Sec. IIIC, Alg. 1.
% Note the constant multiplier log(2)/nv has been moved to the
% inverse of the normalization constant, as calculated in synsq_adm.m
%
% 1. I. Daubechies, J. Lu, H.T. Wu, "Synchrosqueezed Wavelet Transforms: a
% tool for empirical mode decomposition", 2010.
%
% 2. E. Brevdo, N.S. Fučkar, G. Thakur, and H-T. Wu, "The
% Synchrosqueezing algorithm: a robust analysis tool for signals
% with time-varying spectrum," 2011.
%  
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function [Tx,fs] = synsq_cwt_squeeze(Wx, w, t, nv, opt)
    dt = t(2)-t(1);
    dT = t(end)-t(1);
    
    % Maximum measurable frequency of data
    %fM = 1/(4*dt); % wavelet limit - tested
    fM = 1/(2*dt); % standard
    % Minimum measurable frequency, due to wavelet
    fm = 1/dT; % really
    %fm = 1/(2*dT); % standard

    [na, N] = size(Wx);
    as = 2^(1/nv) .^ [1:1:na]';
    das = [1; diff(as)];
    lfm = log2(fm); lfM = log2(fM);
    fs = 2.^linspace(lfm, lfM, na);
    %dfs = [fs(1) diff(fs)];

    % Harmonics of diff. frequencies but same
    % magnitude have same |Tx|
    dfs = ones(size(fs));

    % The rest of the computation is performed efficiently in MEX
    if norm(Wx,'fro') < eps,
      Tx = zeros(size(Wx));
    else
      Tx = 1/nv * synsq_cwt_squeeze_mex(Wx, w, as, fs, dfs, lfm, lfM);
    end
end

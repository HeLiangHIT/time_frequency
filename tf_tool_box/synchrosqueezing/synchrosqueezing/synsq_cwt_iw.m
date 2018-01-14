% function x = synsq_cwt_iw(Tx, fs, opt)
%
% Inverse Synchrosqueezing transform of Tx with associated
% frequencies in fs.  This implements Eq. 5 of [1].
%
% 1. E. Brevdo, N.S. Fučkar, G. Thakur, and H-T. Wu, "The
% Synchrosqueezing algorithm: a robust analysis tool for signals
% with time-varying spectrum," 2011.
%
% Input:
%   Tx, fs: See help synsq_cwt_fw
%   opt: options structure (see help synsq_cwt_fw)
%      opt.type: type of wavelet used in synsq_cwt_fw
%
%      other wavelet options (opt.mu, opt.s) should also match
%      those used in synsq_cwt_fw
%
% Output:
%   x: reconstructed signal
%
% Example:
%   [Tx,fs] = synsq_cwt_fw(t, x, 32); % Synchrosqueezing
%   Txf = synsq_filter_pass(Tx, fs, -Inf, 1); % Pass band filter
%   xf = synsq_cwt_iw(Txf, fs);  % Filtered signal reconstruction
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function x = synsq_cwt_iw(Tx, fs, opt)
    if nargin<3, opt = struct(); end
    if ~isfield(opt, 'type'), opt.type = 'morlet'; end

    % Find the admissibility coefficient Cpsi
    Css = synsq_adm(opt.type, opt);
    
    [na, N] = size(Tx);

    % Integration
    % Due to linear discretization of integral in log(fs), this becomes
    % a simple normalized sum.
    x = real(1/Css * ones(1,na) * Tx);
end

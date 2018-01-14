% function gamma = est_riskshrink_thresh(Wx, nv)
%
% Estimate the RiskShrink hard thresholding level.
%
% Implements Defn. 1 of Sec. 2.4 in [1], using the suggested
% noise estimator from the discussion "Estimating the noise level"
% in that same section.
%
% 1. Donoho, D.L.; I.M. Johnstone (1994), "Ideal spatial adaptation by
%    wavelet shrinkage," Biometrika, vol 81, pp. 425–455.
%
% Inputs:
%  Wx: wavelet transform of a signal, see help cwt_fw
%  opt: options structure used for forward wavelet transform.
%
% Output:
%  gamma: the RiskShrink hard threshold estimate
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function gamma = est_riskshrink_thresh(Wx, nv)
    % TODO, error if opt has no nv, or no opt.
    if nargin<2, opt = struct(); end

    [na, n] = size(Wx);

    Wx_fine = abs(Wx(1:nv, :));

    gamma = sqrt(2*log(n)) * mad(Wx_fine(:)) * 1.4826;

end % est_riskshrink_thresh

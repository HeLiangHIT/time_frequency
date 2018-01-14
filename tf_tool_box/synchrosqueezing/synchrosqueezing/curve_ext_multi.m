% [Cs, Es] = curve_ext_multi(Tx, log2(fs), nc, lambda, clwin) 
%
% Consecutively extract maximum energy / minimum curvature curves
% from a synchrosqueezing representation.  As curves are extracted,
% their associated energies are zeroed out in the synsq
% representation.  Curve extraction is then again performed on
% the remaining representaton.
%
% For more details, see help curve_ext and Sec. IIID of [1].
%
% 1. E. Brevdo, N.S. Fučkar, G. Thakur, and H-T. Wu, "The
% Synchrosqueezing algorithm: a robust analysis tool for signals
% with time-varying spectrum," 2011.
%
% Input:
%  Tx, fs, lambda - same as input to curve_ext() (lambda default = 1e3)
%  nc - Number of curves to extract
%  clwin - frequency clearing window; after curve extraction, a window
%    of frequencies [Cs(:,i)-clwin:Cs(:,i)+clwin] is removed from the
%    original representation. (default = 2)
%
% Output:
%  Cs - [N x nc] matrix of curve indices (N==size(Tx,2))
%  Es - [nc x 1] vector of associated (logarithmic) energies
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function [Cs, Es] = curve_ext_multi(Tx, lfs, nc, lambda, clwin)
if nargin<5, clwin = 4; end
if nargin<4, lambda = 1e3; end

[na, N] = size(Tx);

Cs = zeros(N, nc);
Es = zeros(nc, 1);

for ni=1:nc
    [Cs(:,ni), Es(ni)] = curve_ext(Tx, lfs, lambda);

    % Remove this curve from the representation
    % Max/min frequencies for each time step
    for cli=0:clwin
        fb = max(1, Cs(:,ni)-cli);
        fe = min(na, Cs(:,ni)+cli);
        Tx([0:N-1]'*na+fb) = sqrt(eps);
        if cli>0, Tx([0:N-1]'*na+fe) = sqrt(eps); end
    end
end

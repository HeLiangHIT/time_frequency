% function xrs = curve_ext_recon(Tx, fs, Cs, opt, clwin)
%
% Reconstruct the curves given by curve_ext or curve_ext_multi
%
% Input:
%  opt: same as input to synsq_cwt_fw/iw
%  Tx, fs, clwin: same as input to curve_ext_multi
%  Cs: same as output of curve_ext_multi
% Output:
%  xrs: [n x Nc] matrix - the Nc reconstructed signals (each length n)
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function xrs = curve_ext_recon(Tx, fs, Cs, opt, clwin)

if nargin<5, clwin = 4; end
if nargin<4, opt = struct(); end

Nc = size(Cs, 2);
[na, N] = size(Tx);

assert(na == length(fs));

% Reconstruct the signal for each curve
xrs = zeros(N, Nc);
for ni=1:Nc
    cmask = zeros(size(Tx));
    cmask((0:N-1)'*na + Cs(:,ni)) = 1;
    cmask = imdilate(cmask, ones(clwin,1));
    xrs(:,ni) = synsq_cwt_iw(Tx .* cmask, fs, opt);
end

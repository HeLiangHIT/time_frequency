% function [qTx,Lbdi,Rbdi] = synsq_filtered_time_quantile(Tx, t, fs, opt, q)
% function [qWx,Lbdi,Rbdi] = synsq_filtered_time_quantile(Wx, t, as, opt, q)
%
% Intelligent quantile of positive values in Tx (resp. Wx).
% Removes boundary-affected values before calculating quantiles.
%
% Input:
%   Tx, t, fs: e.g., output of synsq_cwt_fw
%  or
%   Wx, t, as: e.g., output of cwt_fw
%
%   Tx and Wx are size na x n
%   
%   opt: options struct (see, e.g., help tplot_power)
%      opt.filter: filter out boundary elements before computing
%                  quantiles?  (default: 1)
%      opt.style: type of input.  use 'freq' if Tx, 'scale' if Wx
%                 (default: 'freq')
%
%   q: vector of quantiles, length: nq
%
% Output:
%   qTx: quantiles of Tx>0 (resp. Wx>0), possibly filtered, at each
%        row.  one column for each entry in q.  Total size: [na x nq]
%   Lbdi: indices of left boundary, for each row
%   Rbdi: indices of right boundary, for each row
%         (see help synsq_bd_loc or cwt_bd_loc)
%
% Example:
%   aWx_qs = synsq_filtered_time_quantile(abs(Wx), t, as, struct('style','scale'), [.25 .5 .75]);
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function [qTx,Lbdi,Rbdi] = synsq_filtered_time_quantile(Tx, t, fs, opt, q)

if nargin<5, q = .5; end
if nargin<4, opt = struct(); end

[na0, n] = size(Tx);

if ~isfield(opt, 'filter'), opt.filter = 1; end
if ~isfield(opt, 'style'), opt.style = 'freq'; end

% Find boundary limits and clear them - useful for analyzing the mean
if findstr(opt.style, 'freq'),
  [Lbdi, Rbdi] = synsq_bd_loc(t, fs);
elseif findstr(opt.style, 'scale'),
  [Lbdi, Rbdi] = cwt_bd_loc(t, fs);
else
  warning('Unknown style: %s', opt.style);
  Lbdi = []; Rbdi = [];
end
  
% Filter first, to calculate mean
Ltime = t(Lbdi); Rtime = t(Rbdi);
% Nonstandard use of filter_pass; filtering from start time to end
% time for each frequency bin (thus using transposes)
if (opt.filter)
    Tx = synsq_filter_pass(Tx.', t, Ltime, Rtime).';
end

% Zero-valued entries are missing information, set them to NaN so
% quantile() does not use them in estimates.  Note that the only
% elements with estimates of exactly zero must be empty bins.
Tx(~Tx) = NaN;

%muTx = mean(Tx,2);
qTx = equantile(Tx, q, 2);
%qTx = mean(Tx,2);

% Must normalize the means properly - account for the empty spots
% When normalizing, make a little correction for small sample sets: add 1
%LRlen = max(1,Rbdi-Lbdi+1);
%qTx = qTx * n ./ (LRlen(:)+1);

% Normalize again to get approx true magnitude
%qTx = na0*qTx;

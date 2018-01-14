% function qs = equantile(X, ps, dim)
%
% Calculates empirical (non-smoothed) quantiles of multidimensional
% arrays.  Ignores NaN entries.  Faster than, but similar to, the
% quantile() function in the MATLAB Statistics toolbox.
%
% Input:
%  X: multidimensional vector/matrix over which to calculate
%     empirical quantiles.
%  ps: vector of quantile values (between 0 and 1)
%  dim: (optional) dimension along which to calculate quantiles
%
% Output:
%  qs: vector/matrix of empirical quantiles
%
%---------------------------------------------------------------------------------
%    Author: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function qs = equantile(X,ps,dim)

ndX = ndims(X);
sX = size(X);
psn = length(ps);

assert(all(ps >= 0 & ps <= 1));

needsort = 0;
if nargin<3
  % Sort properly depending on data
  if isvector(X) && ~issorted(X)
    needsort = 1;
  elseif ndX <= 2 && ~issorted(X,'rows')
    needsort = 1;
  elseif ndX > 2
    needsort = 1;
  end

  % Which dimension are we calculating quantiles along?
  if isvector(X)
    [tmpvar,mdim] = max(sX);
    dim = mdim;
  else
    dim = 1;
  end
else
  needsort = 1;
end

% Reshape data to make ensuing steps easier (quantile-dim becomes first dim)
dperm = 1:ndX;
dperm([1 dim]) = dperm([dim 1]);
if (dim ~= 1)
  X = permute(X, dperm);
end
sXperm = sX(dperm);

% Reshape to 2D; we calculate quantiles along first dimension
X = reshape(X, sX(dim), prod(sX([1:dim-1, dim+1:ndX])));

if (needsort),
  X = sort(X,1);
end

% If we see NaNs, need to calculate quantiles row-by-row.
% Otherwise can do it in one fell swoop.
Xnan = isnan(X);
if any(any(Xnan,2))
  hasnan = 1;
else
  hasnan = 0;
end

if (~hasnan)
  ks = round(ps*(sX(dim)-1) + 1); 
  assert(all(ks >= 1 & ks <= sX(dim)));
  qs = X(ks,:);
else % if (hasnan)
  ns = zeros(size(X,2), 1);
  qs = nan(psn, size(X,2));

  % Limit ourselves to non-NaN values
  for ci=1:size(X,2)
    ni = find(Xnan(:, ci), 1, 'first')-1;
    % If don't find any NaNs, use full dim
    if isempty(ni), ni = sX(dim); end

    ns(ci) = ni;
  end

  % Calculate quantiles in each case
  Xcol = 1:size(X,2);
  for pi=1:psn
    p = ps(pi);
    ks = round(p*(ns-1)+1);
    % Pull out the proper elements of sorted X
    qs(pi,ks>0) = X(sub2ind(size(X), ks(ks>0)', Xcol(ks>0)));
  end
end

% Convert back to ndim array
qs = reshape(qs, [psn, sX(1:dim-1), sX(dim+1:ndX)]);

% Move coordinates back to their proper places
if (dim ~= 1)
  qs = ipermute(qs, dperm);
end

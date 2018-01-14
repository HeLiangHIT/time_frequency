% function lcs = plot_markers(x,ys,ms,varargin)
%
% Plots curves with a reasonable number of markers each
%
% Inputs:
%   x:  shared x coordinates
%   ys: column vectors of curve data (size(ys,2)==length(x))
%   ms: cell of marker strings, e.g., {'+','*','o'}
%   varargin: other parameters to send to plot()
%
% Outputs:
%   lcs: line handles for the legend
%
% Example:
%   t = linspace(0,10,1024)';
%   lcs = plot_markers(t, [sin(t) cos(t)], {'+','*'}, 'Color', 'k', 'LineWidth', 2);
%   legend(lcs, {'sin(t)', 'cos(t)'});
%
%---------------------------------------------------------------------------------
%    Author: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function lcs = plot_markers(x,ys,ms,varargin)

assert(length(x)==numel(x)); % A time vector
if length(ys)==numel(ys)
  ys = ys(:); % Turn to col vec
end
assert(size(ys,1)==length(x));

Nm = length(ms);
n = length(x);
p = size(ys,2);
nsub = 31;
npick = round(n/nsub);
pick = 1:npick:n;

lcs = [];

for pi=1:p
  plot(x,ys(:,pi),varargin{:});
  if (pi==1) hold on; end
  plot(x(pick),ys(pick,pi), varargin{:}, ...
       'Marker',ms{1+mod(pi-1,Nm)}, 'LineStyle', 'none');
  lcs = [lcs plot(x, ys(:,pi), varargin{:}, ...
                  'Visible', 'off', 'Marker', ms{1+mod(pi-1,Nm)})];
end

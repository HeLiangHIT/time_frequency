% function [up,n1,n2] = p2up(n)
%
% Calculates next power of 2, and left/right padding to center the
% original n locations.
%
% Input:
%   n: non-dyadic integer
% Output:
%   up: next power of 2
%   n1: length on left
%   n2: length on right
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function [up,n1,n2] = p2up(n)
    up = 2^(1+round(log2(n+eps)));
    n1 = floor((up-n)/2); n2 = n1;
    if (mod(2*n1+n,2)==1), n2 = n1 + 1; end
end

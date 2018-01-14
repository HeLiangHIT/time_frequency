% function [Lbdi, Rbdi] = cwt_bd_loc(t, as)
%
% For a given time series and set of scale values, calculate the left
% and right boundaries for each scale.  Beyond these boundaries,
% boundary effects affect the signal.  Output is in indices.
%   If length(t)==n, then length(Lbdi)==length(Rbdi)==n
%
% t is assumed to be sampled uniformly
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function [Lbdi, Rbdi] = cwt_bd_loc(t, as)
    dt = t(2)-t(1);
    asn = ceil(as / dt);

    Lbdi = min(length(t), asn);
    Rbdi = max(1, length(t)-asn);
end
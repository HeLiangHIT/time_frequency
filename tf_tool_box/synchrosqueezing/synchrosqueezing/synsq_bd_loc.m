% function [Lbdi, Rbdi] = synsq_bd_loc(t, fs)
%
% For a given time series and set of frequency values, calculate the left
% and right boundaries for each frequency.  Beyond these boundaries,
% boundary effects affect the signal.  Output is in indices.
%   If length(t)==n, then length(Lbdi)==length(Rbdi)==n
% 
% t is assumed to be sampled uniformly
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function [Lbdi, Rbdi] = synsq_bd_loc(t, fs)
    if (fs(2)>fs(1))
        Ts = 1./fs;
    else
        Ts = fs;
    end

    dt = t(2)-t(1);
    Tsn = ceil(1.5 * Ts / dt);

    Lbdi = min(length(t), Tsn);
    Rbdi = max(1, length(t)-Tsn);
end

% function [Txf,fmi,fMi] = synsq_filter_pass(Tx, fs, fm, fM)
%
% Filters the Synchrosqueezing representation Tx, having associated
% frequencies fs (see help synsq_cwt_fw).
% This band-pass filter keeps frequencies in the
% range [fm, fM].
%
% Inputs:
%   Tx, fs: e.g., output of synsq_cwt_fw
%   fm, fM: Minimum and maximum band pass values, respectively.
%     fm,fM may be scalars, or vectors with each value associated
%     with a time index (length(fm)==length(fM)==size(Tx,2)).
% 
% Outputs:
%   Txf: Filtered version of Tx (same size), with zeros outside the
%        pass band rows.
%   fmi: time-length vector of min-frequency row indices
%   fMi: time-length vector of max-frequency row indices
% Example:
%   % Remove all energy for normalized frequencies above 1.
%   [Txf,fmi,fMi] = synsq_filter_pass(Tx, fs, -Inf, 1); 
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function [Txf,fmi,fMi] = synsq_filter_pass(Tx, fs, fm, fM)

if length(fm) == 1, fm = fm*ones(1,size(Tx,2)); end
if length(fM) == 1, fM = fM*ones(1,size(Tx,2)); end

if length(fm) ~= size(Tx, 2)
    error('fm does not match t-length of Tx');
end

if length(fs) ~= size(Tx,1)
    error('fs does not match Tx');
end

fmi = zeros(length(fm),1);
fMi = zeros(length(fm),1);
Txf = zeros(size(Tx));
for ti=1:length(fm)
    fmi(ti) = find(fs >= fm(ti), 1, 'first');
    fMi(ti) = find(fs <= fM(ti), 1, 'last');
    Txf(fmi(ti):fMi(ti), ti) = Tx(fmi(ti):fMi(ti), ti);
end

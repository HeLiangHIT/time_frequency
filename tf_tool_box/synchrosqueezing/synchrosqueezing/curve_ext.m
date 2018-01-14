% [C, E] = curve_ext(Tx, log2(fs), lambda);
%
% Extract a maximum energy, minimum curvature, curve from
% Synchrosqueezed Representation.  Note, energy is given as:
%   abs(Tx).^2
%
% This implements the solution to Eq. (8) of [1].
%
% 1. E. Brevdo, N.S. Fučkar, G. Thakur, and H-T. Wu, "The
% Synchrosqueezing algorithm: a robust analysis tool for signals
% with time-varying spectrum," 2011.
%
% Original Author: Jianfeng Lu (now at NYU CIMS)
% Maintainer: Eugene Brevdo
%
% Inputs:
%   lambda should be >=0.  Default: lambda=0
%
% Outputs:
%   C: the curve locations (indices)
%   E: the (logarithmic) energy of the curve
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------

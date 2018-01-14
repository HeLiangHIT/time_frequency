% Forward and Inverse Fast Wavelet Transforms
%
% Usage:
%   output = wlet( signal, [output_type [, num_coeff [, direction]]])
%
%
%   Parameters:
%
%      output_type is one of:
%
%         1  Output is one dimensional, and represents the raw result 
%            from the fast wavelet transform algorithm (wavelet coefficients).
%            This is the default.
%            
%
%         2  Output is two dimensional. This output format is convenient for
%  	     displaying transformed data as a time-scale matrix (scalogram).
%
%      num_coeff 
%       
%         gives the number of filter coeffients used in approximating
%         the wavelet.  Possible values are 4, 12 or 20, and the default is 20.
%
%      direction 
%
%         1  Transform is forward, from time domain to time-scale
%	     domain. (default)
%
%        -1  Transform is reverse, from time-scale domain to time domain.
%
%
% Two dimensional output can only be used with the forward transform, and
% the input to both forward and reverse transforms must be one-dimensional.
%
% TFSAP 7.0
% Copyright Prof. B. Boashash
% Qatar University, Doha
% email: tfsap.research@gmail.com

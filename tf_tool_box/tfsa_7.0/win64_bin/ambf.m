% Ambiguity function
%
% Computes the ambiguity function of the input signal. An analytic
% signal generator is called if the input signal is real. This version
% takes advantage of the property K(n,-m)=K*(n,m) to increase
% calculation speed.
%
% Usage: 
%
%     af = ambf( signal, lag_res, window_length )
%
%
% Parameters:
%
%     af
%
%	  The computed ambiguity function representation. size(af) will
%	  return [a, b], where b is the next largest power of two above
%	  (2*window_length), and a is equal signal length.
%
%    signal
%
%	  Input one dimensional signal to be analysed. An analytic signal
%	  is required for this function, however, if signal is real, a
%	  default analytic transformer routine will be called from this
%	  function before computing the ambiguity function.
%
%    window_length
%
%	  The number of signal samples used for analysis.
%
%    lag_res
%
%	  The number of lag to skip between successive slices of
%	  the analysis.
%
%
%
%  See Also: analyt
%
% TFSAP 7.0
% Copyright Prof. B. Boashash
% Qatar University, Doha
% email: tfsap.research@gmail.com


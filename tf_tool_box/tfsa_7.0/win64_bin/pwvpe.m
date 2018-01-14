% Peak of polynomial Wigner-Ville frequency estimation
%
% Estimates the instantaneous frequency of the input signal by
% extracting the peaks of the sixth order kernel polynomial
% Wigner-Ville distribution.
%
%
% Usage:
%
%     ife = pwvpe( signal, lag_window_length, time_res, interpol [, fft_length] ))
%
%
% Parameters:
%
%    signal
%
%         Input one dimensional signal to be analysed. An analytic signal
%	  is required for this function, howver, if signal is real, a
%	  default analytic transformer routine will be called from this
%	  function before computing tfd.
%
%    lag_window_length
%
%	  The size of the kernel used for analysis. window_length must be
%	  odd. The kernel used will be defined from -(lag_window_length+1)/2 to
%	  +(lag_window_length+1)/2 in both time and lag dimensions.
%
%    time_res
%
%	  The number of time samples to skip between successive slices of
%	  the analysis.
%
%    interpol
%
%	  The number of interpolating the input signal in time domain to get
%	  the proper time fractional time lags required to compute the sixth
%         order kernel.
%
%    fft_length
%
%         Zero-padding at the fft stage of the analysis may be specified by
%         giving an fft_length larger than normal. If fft_length is not
%         specified, or is smaller than the lag_window_length, then the
%         next highest power of two above lag_window_length is used. If
%         fft_length is not a power of two, the next highest power of two is
%	  used.
%
%
%
%  See Also: pwvd4, pwvd6
%
% TFSAP 7.0
% Copyright Prof. B. Boashash
% Qatar University, Doha
% email: tfsap.research@gmail.com

% Wigner-Ville distribution
%
% Computes the wvd of the input signal. An analytic signal
% generator is called if the input signal is real. The supplied
% length of the analysis window defines whether the "true" wvd or
% a pseudo (windowed) wvd is computed. This version takes
% advantage of the reality of the wvd to increase calculation
% speed.
%
% Usage:
%
%     tfd = wvd(signal, [lag_window_length] [,time_res] [, fft_length] )
%
% Parameters:
%
%    signal
%
%	  Input one dimensional signal to be analysed. An analytic signal
%	  is required for this function, however, if signal is real, a
%	  default analytic transformer routine will be called from this
%	  function before computing tfd.
%
%    lag_window_length
%
%	  This is the data window length and controls the size of
%	  the kernel used for analysis (lag_window_length must	be
%	  odd). The kernel used will be defined from -(lag_window_length+1)/2
%	  to +(lag_window_length+1)/2 in both time and lag dimensions.
%
%    time_res
%
%	  The number of time samples to skip between successive slices.
%	  Default vaule is 1.
%
%    fft_length
%
%	  Zero-padding at the FFT stage of the analysis may be specified by
%	  giving an fft_length larger than lag_window_length. If fft_length
%	  is not specified, or is smaller than the lag_window_length, then the
%	  next highest power of two above lag_window_length is	used. If
%	  fft_length is not a power of two, the next highest power of two is
%	  used.
%
%     tfd
%
%	  The computed time-frequency distribution. size(tfd) will
%	  return [a, b], where a is the next largest power of two above
%	  fft_length, and b is floor(length(signal)/time_res) - 1.
%
%
%
%  See Also: analyt, quadtfd
% TFSAP 7.0
% Copyright Prof. B. Boashash
% Qatar University, Doha
% email: tfsap.research@gmail.com

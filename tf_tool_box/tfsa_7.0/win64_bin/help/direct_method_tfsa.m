% GENERATE BILINEAR TIME-FREQUENCY TRANSFORMATIONS USING THE DIRECT METHOD
%
% BILINEAR TRANSFORMATIONS transform the time domain signal (the
% variable INPUT SIGNAL) to an output time-frequency distribution (the
% variable OUTPUT TIME-FREQUENCY ARRAY)
%
% These functions use a direct implementation rather than using the
% quadratic time-frequency implementation. This results in a
% computationally optimised routine.
% 
% The different types of time-frequency distributions that can be
% implemented directly are:
%   
%   (i)    Wigner-Ville Distribution 
%   (ii)   Short-Time Fourier Transform
%   (iii)  Short-Time Fourier Transform(overlap)
%   (iv)   Rihaczek
%   (v)    Windowed-Rihaczek
%
%   The various parameters associated with the distributions are as follows:
%
%   TIME-FREQUENCY ARRAY (tfd)
%
%      The computed time-frequency distribution.  size(tfd) will
%      return [a, b], where a is the next largest power of two above
%      FFT length, and b is floor(length(signal)/time_res) - 1.
%
%   INPUT SIGNAL
%
%      Input one dimensional signal to be analysed. An analytic signal
%      is required for this function, however, if signal is real, a
%      default analytic transformer routine will be called from this
%      function before computing tfd.
%
%   TIME RESOLUTION
%
%      The number of time samples to skip between successive time slices.
%
%   LAG WINDOW LENGTH
%
%      This is the lag window length and controls the size of the
%      signal kernel (or instantaneous autocorrelation function) used
%      for analysis (lag_window_length must be odd). The kernel used
%      will be defined from -(lag_window_length+1)/2 to
%      +(lag_window_length+1)/2 in both time and lag dimensions.
%
%   FFT Length:
%
%      Zero-padding at the FFT stage of the analysis may be specified
%      by giving an FFT length larger than lag window length.  If
%      FFT length is not specified, or is smaller than the
%      lag window length, then the next highest power of two above
%      lag window length is used.  If FFT length is not a power of
%      two, the next highest power of two is used.
%
%
%
%  See Also:  wvd, spec, rihaczek, analyt

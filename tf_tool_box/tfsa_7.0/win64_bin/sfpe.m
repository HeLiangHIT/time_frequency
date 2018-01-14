% Peak of spectrogram frequency estimation
%
% Estimates the instantaneous frequency of the input signal by extracting
% the peaks of the spectrogram.
%
%
% Usage:
%
%     ife = sfpe (signal, window_length, time_res [, fft_length] )
%
% Parameters:
%
%    signal
%
%	  Input one dimensional signal to be analysed.	An analytic signal
%	  is required for this function, however, if signal is real, a
%	  default analytic transformer routine will be called from this
%	  function before computing spectrogram.
%
%    window_length
%
%	  The size of the kernel used for analysis. window_length must
%	  be odd. The kernel used will be defined from -(window_length+1)/2 to
%	  +(window_length+1)/2 in both time and lag dimensions.
%
%    time_res
%
%	  The number of time samples to skip between successive slices of
%	  the analysis.
%
%    fft_length
%
%         Zero-padding at the fft stage of the analysis may be specified by
%         giving an fft_length larger than normal. If fft_length is not
%	  specified then the next highest power of two above the
%         signal length will be used. If fft_length is not a power
%         of two, then the next highest power of two is used.
%
%
%
%  See Also: spec
% TFSAP 7.0
% Copyright Prof. B. Boashash
% Qatar University, Doha
% email: tfsap.research@gmail.com



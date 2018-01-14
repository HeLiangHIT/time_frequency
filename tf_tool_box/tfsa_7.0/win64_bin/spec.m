% Spectrogram estimate using the direct realisation
%
% Usage:
%
%     tfd = Stft (signal, time_res, window_length, window_type [, fft_length] 
%		    [, stft_or_spec ] )
%
% Parameters:
%
%    signal
%
%         Input one dimensional signal to be analysed. An analytic signal
%         is required for this function, however, if signal is real, a
%         default analytic transformer routine will be called from this
%         function before computing spectrogram.
%
%    time_res
%
%         The number of time samples to skip between successive slices of
%	  the analysis.
%
%    window_length
%
%         Length of choosen window.
%
%
%    window_type
%
%         One of  'rect', 'hann', 'hamm', 'bart' 
%
%
%    fft_length
%
%         Zero-padding at the fft stage of the analysis may be specified by
%         giving an fft_length larger than normal. If fft_length is not
%         specified then the next highest power of two above the
%         signal length will be used. If fft_length is not a power
%         of two, then the next highest power of two is used.
%
%    stft_or_spec
%
%         Returns either Short Time Fourier Transform (STFT) or Spectrogram
%         by specifying:
%         
%                  0           Spectrogram (default)
%                  1           STFT
%
%
%    tfd
%
%        The computed time-frequency distribution. size(tfd) will
%        return [a/2+1, b], where a is the next largest power of two above
%        window_length, and b is floor(length(signal)/time_res) -
%        1.
%
%
%
%  See Also: analyt
% TFSAP 7.0
% Copyright Prof. B. Boashash
% Qatar University, Doha
% email: tfsap.research@gmail.com


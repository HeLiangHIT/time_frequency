% Computation of the S_Method
% Usage:
%
%       output = S_method( input1, L, wl, win, param_overlap, fftl);
% 
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
%    L
%
%        Define the length of frequency window in the S-Method (2*L+1)
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
%   overlap
%      
%         Number of samples in common between two consecutives windows.
%         0 < overlap < window_length.
% 
%    fft_length
%
%         Zero-padding at the fft stage of the analysis may be specified by
%         giving an fft_length larger than normal. If fft_length is not
%         specified then the next highest power of two above the
%         signal length will be used. If fft_length is not a power
%         of two, then the next highest power of two is used.
%
%
%    tfd
%
%        The computed time-frequency distribution. size(tfd) will
%        return [a/2+1, b], where a is the next largest power of two above
%        window_length, and b is ceil((length(signal)-overlap)/(window_length-overlap)) .
%
%
%
%  See Also: spec
% TFSAP 7.0
% Copyright Prof. B. Boashash
% Qatar University, Doha
% email: tfsap.research@gmail.com


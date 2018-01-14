% Rihaczek and Levin Distributions (direct implementation)
%
%
% Usage:
%
%     tfd =  rihaczek (signal [, time_res ] [, fft_length ] [, rih_levin ] 
%			 [ window_length ] [, window_type ] )
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
%
%    fft_length
%
%	  Zero-padding at the fft stage of the analysis may be specified by
%	  giving an fft_length larger than normal.  If fft_length is not
%	  specified, or is smaller than the signal_length, then the
%	  next highest power of two above signal_length is used. If
%	  fft_length is not a power of two, the next highest power of two is
%	  used.
%
%    time_res
%
%	  The number of time samples to skip between successive slices of
%	  the analysis.
%
%    rih_levin
%
%	  Option to specify whether to return the Rihaczek distribution or the
%         Levin distribution.
%       
%         0        Rihaczek (default)
%         1        Levin
%
%    window_length
%
%         If this parameter is specified then the windowed distribution is used.
%	  window_length must be odd.	
%         
%
%    window_type
%
%         One of  'rect', 'hann', 'hamm', 'bart' 
%
%    tfd
%
%	  The computed time-frequency distribution. size(tfd) will
%	  return [a/2+1, b], where a is the next largest power of two above
%	  signal_length, and b is floor(length(signal)/time_res) - 1.
%
%
%
%  See Also: analyt
%
% TFSAP 7.0
% Copyright Prof. B. Boashash
% Qatar University, Doha
% email: tfsap.research@gmail.com



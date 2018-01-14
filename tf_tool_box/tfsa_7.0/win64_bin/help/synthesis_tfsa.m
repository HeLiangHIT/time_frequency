% SIGNAL SYNTHESIS
%
% Estimates the time-domain signal from a given time-frequency distribution.
%
%
% The signal synthesis routine is limited to the following
% time-frequency distributions:
% 
%    (i)   Short-Time Fourier Transform (STFT)
%    (ii)  Spectrogram
%    (iii) Wigner-Ville Distribution
%
% PARAMETERS:
%
%   TIME-FREQUENCY MATRIX
%
%	Input matrix containing the time-frequency distribution.
%
%   SIGNAL
%
%       Output synthesised (complex) signal from given time-frequency distribution.
%
%   WINDOW LENGTH
%
%      Length of the smoothing window used in the given distribution (or in the case of
%      of the WVD the lag window length).
%
%   ANALYSIS TYPE
%
%      Specifies which type of signal synthesis will be applied to the given TFD 
%      matrix. The following analysis types are valid:
%
%      (i) STFT:
%
%         (a) Inverse Discrete Fourier Transform method.
%         (b) Overlap-Add method.
%         (c) Modified Short-Time Fourier Transform method.
%
%      (ii) Spectrogram:
%
%         Modified Spectrogram method
%
%      (iii) Wigner Ville Distribution:
%
%         Wigner Ville Distribution method. The original signal can be
%         specified to correct the phase of the synthesised signal.
%
%
%
%  See Also:  wvd, spec



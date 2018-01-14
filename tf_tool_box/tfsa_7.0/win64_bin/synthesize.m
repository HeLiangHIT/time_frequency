% Routine to synthesize signal from given TFD
%
%
% Usage:
%
%     signal = synthesize( tfd, analysis_type , window_length , [ analysis_params], 
%              [ original_signal ] )
%
%
% Parameters:
%
%
%    signal
%
%         Synthesized (complex) signal from gived TFD.
%
%
%    tfd
%
%         Matrix containing the time-frequency distribution for a given signal.
%
%
%    analysis_type
%
%         Specifies which type of signal synthesis will be applied to the given TFD 
%         matrix. The following analysis types are valid:
%
%         If the TFD is a Short-Time Fourier Transform Distribution:
%
%             'idft'           Inverse Discrete Fourier Transform method
%             'ola'            OverLap-Add method
%             'mstft'          Modified Short-Time Fourier Transform method
%
%
%         If the TFD is a Spectrogram Distribution:
%
%             'mspec'          Modified Spectrogram method
%
%
%         If the TFD is a Wigner Ville Distribution:
%
%             'wvd'          Wigner Ville Distribution method
%
%
%    window_length
%
%         Length of the smoothing window used in the given distribution (or in the case of
%         of the WVD the lag window length).
%
%    analysis_params:
%     
%         Some of the anaylsis types require parameters:
%
%         'idft' 
%               analysis_params1 = window type
%         'ola' 
%               analysis_params1 = window type
%         'mstft' 
%               analysis_params1 = window type
%         'mspec' 
%               analysis_params1 = window type
%               analysis_params2 = tolerance value for iteration routine
%
%
%    original_signal
%
%         Original signal can be supplied to correct the phase of the synthesized signal.
%
%
%
%
%  See Also: spec, wvd, analyt
% TFSAP 7.0
% Copyright Prof. B. Boashash
% Qatar University, Doha
% email: tfsap.research@gmail.com


  

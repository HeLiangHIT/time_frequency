% INSTANTANEOUS FREQUENCY ESTIMATION
%
% Includes different methods to estimate the instantaneous frequency
% for given time-domain signal
%
% These different techniques include:
%
%   (i)    Finite Phase Difference
%   (ii)   Weighted Phase Difference
%   (iii)  Zero-Crossing
%   (iv)   Adaptive Estimators
%   (v)    Least Squares
%   (vi)   Peak of Spectrogram
%   (vii)  Peak of Wigner-Ville Distribution
%   (viii) Peak of Polynomial Wigner-Ville Distribution
%
%   PARAMETERS:
%
%   SIGNAL
%        
%       One dimensional input signal.
%   
%   ESTIMATED FREQUENCY ARRAY
%   
%       One dimensional output signal containing the estimated
%       instantaneous frequency (IF) law for given input signal.
%
%
%   EXPLANATION OF VARIOUS TECHNIQUES:
%  
%   (i) Finite Phase Difference
%
%       Estimates the IF law of the input signal using the general
%       phase difference method. Only first, second, fourth and sixth
%       order phase difference estimators are available in the case
%       when no smoothing is required. The signal phase is unwrapped
%       when a fourth or a sixth order estimator is applied
%
%   (ii) Weighted Phase Difference
%
%       This function uses the Kay weighted difference estimator. A
%       sliding Kay window is used to smooth the phase. The local
%       smoothed estimate inside the moving quadratic window is
%       computed each time the window moves.  
%
%   (iii) Zero Crossings
%
%       Estimates the IF law of the input signal using the
%       zero-crossing estimation algorithm. It estimates the frequency
%       by taking the average number of zero-crossings within a
%       sliding window.
%
%   (iv) Adaptive Estimators
%
%       Two methods can be selected here, the least mean square (LMS)
%       adaptive IF estimator and the recursive least square (RLS)
%       adaptive IF estimator.  The LMS method is based on a single
%       tap linear prediction filter which has its coefficients
%       updated as each new data sample is received. The positive
%       adaptation constant controls the rate adaptation. The RLS
%       method is based on a single tap linear prediction filter which
%       has its coefficients updated as each new data sample is
%       received. The forgetting factor controls the rate of
%       adaptation. Both the adaptation constants must be positive.
%
%   (v) Least Squares 
%
%       Estimates the IF law of the input signal by obtaining the
%       phase of the input signal and then fitting a polynomial. The
%       order of the polynomial is selected using the parameter
%       order. The order of the polynomial to be fitted to the can be
%       specified.
%
%   (vi) Peak of Spectrogram
%
%       Estimates the IF law of the input signal using the peak of the
%       spectrogram method. SEE ALSO: spec
%
%   (vii) Peak of Wigner-Ville Distribution
%
%       Estimates the IF law of the input signal using the peak of the
%       Wigner-Ville distribution method. SEE ALSO: wvd
%
%   (viii) Peak of Polynomial Wigner-Ville Distribution
%
%       Peak of the sixth order polynomial Wigner-Ville distribution
%       IF estimation algorithm. SEE ALSO: pwvd6
%
%
%
%  See Also:  lms, pde, pwvpe, rls, sfpe, wvpe, zce


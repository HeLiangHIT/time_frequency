% Generate various time and frequency-varying test signals
%
% Usage 1:
%
%   output = gsig( data_type, f1, f2, num_samples, sig_type);
%
%
%   Inputs
%
%	data_type 
%
%          'lin' linear FM
%          'quad' quadratic FM
%          'cubic' cubic FM
%          'hyp' hyperbolic FM
%
%	f1, f2 
%
%          normalised frequency bounds for the signal (i.e. taking
%   	   sampling frequency as 1 Hz) and sig_type=1 for real data 
%          otherwise  the result is complex.
%
%	num_samples 
%
%          is the number of generated data samples.
%
%
%      sig_type
%
%          Must be 0 (analytic) or 1 (real).
%
% Usage 2: 
%
%   output = gsig( 'sin', cf, mf, num_samples, sig_type, fdev );
%
%   
%   Inputs
%
%	cf and mf 
%
%          central and modulation frequencies.
%
%       fdev 
% 
%          frequency deviation.
%
% Usage 3:
%    
%   output1 = gsig( 'step', f1, f2, num_samples, sig_type, ns );
%
%   Inputs
%
%	f1, f2 
%
%          The normalised frequency bounds for the signal (i.e. taking
%	   sampling frequency as 1 Hz). 
%
%       ns
%
%          The number of steps. 
%
%
%
%  See Also: analyt
%
% TFSAP 7.0
% Copyright Prof. B. Boashash
% Qatar University, Doha
% email: tfsap.research@gmail.com





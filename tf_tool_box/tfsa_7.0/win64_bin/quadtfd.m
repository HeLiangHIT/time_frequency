% Generate Quadratic Time-Frequency Distributions
%
% This function generates various members of quadratic time-frequency
% distributions. Predefined members can be specified, or a user defined
% kernel may be used.
%
% Usage:
%
%     tfd = quadtfd( signal, lag_window_length, time_res, kernel
%	  [, kernel options] [,fft_length ] );
%
% kernel is one of: 'wvd', 'smoothed', 'specx', 'rm', 'cw', 'bjc', 'zam',
% 'b', 'mb' or 'emb'.
%
% where
%     tfd
%
%	  The computed time-frequency distribution. size(tfd) will
%	  return [a, b], where a is the next largest power of two above
%	  fft_length, and b is floor(length(signal)/time_res) - 1.
%
%     signal
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
%
%    kernel
%
%	  The determining kernel function.  kernel is a string defining
%	  a predefined kernel. 
%
%	  Predefined types:
%
%             'wvd'         Wigner-Ville
%             'smoothed'    Smoothed Wigner-Ville
%             'specx'       Short-Time Fourier Transform
%             'rm'          Rihaczek-Margenau-Hill
%             'cw'          Exponential
%             'bjc'         Born-Jordan
%             'zam'         Zhao-Atlas-Marks
%             'b'           B-distribution
%             'mb'          Modified B-distribution
%             'emb'         Extended Modified B-distribution
%
%     kernel_options
%
%	  Some kernels require extra parameters:
%
%         'smoothed'
%             kernel_option = length of smoothing window
%             kernel_option2 = type of smoothing window, one of: 'rect','hann','hamm','bart'
%         'specx'
%             kernel_option = length of smoothing window
%             kernel_option2 = type of smoothing window, one of: 'rect','hann','hamm','bart'
%         'cw'
%             kernel_option = Smoothing parameter
%         'zam'
%             kernel_option = ZAM 'a' parameter
%         'b'
%             kernel_option = B-distribution smoothing parameter beta
%         'mb'
%             kernel_option = Modified B-distribution parameter alpha
%         'emb'
%             kernel_option = Extended Modified B-distribution parameters, 
%             alpha and beta
%
%    fft_length
%
%	  Zero-padding at the FFT stage of the analysis may be specified by
%	  giving an fft_length larger than lag_window_length. If fft_length
%	  is not specified, or is smaller than the lag_window_length, then the
%	  next highest power of two above lag_window_length is used. If
%	  fft_length is not a power of two, the next highest power of two is
%	  used.
%
%
%
%  See Also: analyt
% TFSAP 7.0
% Copyright Prof. B. Boashash
% Qatar University, Doha
% email: tfsap.research@gmail.com

% 
% Generate Time-Frequency Distributions Based on Compact Support Kernels
% 
% Usage:
% 
%   tfd = cmpt( signal, kernel [, kernel options]);
%   
%   kernel is one of: 'csk', 'ecsk'.
% 
%   where
% 
%     tfd:
%	  tfd is the computed time-frequency distribution. Size of the TFD will
%	  be [M, N], where M is the next largest power of two of 
%	  signal length, and N is length of the signal.
%
%     signal:
%	  Input one dimensional signal to be analysed. 
%
%     kernel:
%	  The determining kernel function.  kernel is a string defining
%	  a predefined kernel. 
%
%   	  Predefined types:
%
%         'csk'         Compact Support Kernel
%         'ecsk'        Extended Compact Support Kernel
%         
%
%     kernel_options:
%     The parameters to control shape and spread of kernel
% 
%        'csk'
%             C:
%             parameters C controls the shape of compact support kernel
%             D:
%             parameters D controls the spread of compact support kernel
% 
%        'ecsk' corresponds to the CKD
%             C:
%             parameters C controls the shape of extended compact support
%             kernel
%             D, E:
%             parameters D, E controls the spread of extended compact support kernel
%       
% 
%   See Also: gsig
% 
% TFSAP 7.0
% Copyright Prof. B. Boashash
% Qatar University, Doha
% email: tfsap.research@gmail.com


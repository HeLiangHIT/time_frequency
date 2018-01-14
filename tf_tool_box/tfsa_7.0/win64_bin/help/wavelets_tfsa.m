% FOWARD AND INVERSE FAST WAVELET TRANSFORMS
%
%  This function performs the fast wavelet transform. The function
%  transforms the time domain signal to the time-scale domain or the
%  transforms the time-scale distribution to the time domain, i.e.
%  either forward or reverse transforms may be performed by setting
%  the direction parameter. The algorithm implements decomposition
%  into Daubechies wavelets, and uses a pyramidal fitering scheme.
%
%
% PARAMETERS:                                             
%
%  SIGNAL                                                 
%      Input one dimensional signal to be analysed.    
%
%  OUTPUT TYPE                                            
%    One of the following:                                
%       1. Output is one dimensional, and represents the  
%          raw result from the fast wavelet transform.    
%       2. Output is two dimensional. This output is      
%          corresponds to the scalogram.                  
%
%  NUMBER OF COEFFICIENTS                               
%     Number of wavelet coefficients (4, 12 and 20)      
%
%  DIRECTION                                             
%     Either forward transform (time domain to scale     
%     domain) or reverse (time-scale to time domain).    



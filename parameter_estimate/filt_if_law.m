function if_smooth=filt_if_law(if_law,window_length)
%---------------------------------------------------------------------
% filter IF law by convolving with Hamming window
%---------------------------------------------------------------------
if(nargin<2 || isempty(window_length)) window_length=15; end

w=hamming( floor(window_length) ); w=w./sum(w);

if_mean=mean(if_law);
if_smooth=conv(if_law-if_mean,w,'same');
if_smooth=if_smooth+if_mean;

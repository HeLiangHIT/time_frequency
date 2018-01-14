function tfd = tfrAOK(x)
% 计算 adaptive_optimal_kernal_tfd：I_max_new = tfrAOK(x)
% G.A. Reina 16 Jan 2007
% Modified from the C code provided by D. L. Jones and R. G. Baraniuk
% "An Adaptive Optimal-Kernel Time-Frequency Representation"
%   by D. L. Jones and R. G. Baraniuk, IEEE Transactions on Signal
%   Processing, Vol. 43, No. 10, pp. 2361--2371, October 1995.
% 参数：输入x为实数或者复数都行，复数会先取实部然后再转换为解析信号。
% tfd是一个实数矩阵，包含负数。

x = x(:).';%维数匹配

sig_in_tmp=x;
% sig_in_tmp=back_data(ll,:);
sig_in_tmp = hilbert(sig_in_tmp');
sig_in = [real(sig_in_tmp) imag(sig_in_tmp)];


sig_in_tmp = hilbert(sig_in_tmp');
%
if size(sig_in, 1) > size(sig_in, 2)
    xr_tmp = sig_in(:,1)'; % IMPORTANT: Pass vectors as rows
    xi_tmp = sig_in(:,2)';  % IMPORTANT: Pass vectors as rows
else
    xr_tmp = sig_in(1, :); % IMPORTANT: Pass vectors as rows
    xi_tmp = sig_in(2, :);  % IMPORTANT: Pass vectors as rows
end


xlen = length(sig_in);

tlag =256;
fftlen =256;
tstep = 1;
vol=1;
% Allocate the output matrix
ofp = zeros(ceil((xlen + tlag + 2)/tstep), fftlen);

% ===========================================================

if (fftlen < (2*tlag))
    fstep = 2*tlag/fftlen;
    fftlen = 2*tlag;
else
    fstep = 1;
end

nits = log2(tstep+2);   % number of gradient steps to take each time

alpha = 0.01;

mu = 0.5;               % gradient descent factor

forget = 0.001;		% set no. samples to 0.5 weight on running AF
nraf = tlag;		% theta size of rectangular AF
nrad = tlag;		% number of radial samples in polar AF
nphi = tlag;		% number of angular samples in polar AF
outdelay = tlag/2;	% delay in effective output time in samples
% nlag-1 < outdelay < nraf to prevent "echo" effect

nlag = tlag + 1;	% one-sided number of AF lags
mfft = ceil(log2(fftlen));
slen = floor( (sqrt(2)) *(nlag-1) + nraf + 3);	% number of delayed samples to maintain
vol = (2.0*vol*nphi*nrad*nrad)/(pi*tlag);   % normalize volume

polafm2 = zeros(nphi, nrad);
rectafr = zeros(nraf, nlag);
rectafi = zeros(nraf, nlag);

xr = zeros(slen,1);
xi = zeros(slen,1);
sigma = ones(nphi,1);

tlen = xlen + nraf + 2;

% ======================================

[rar,rai,rarN,raiN] = rectamake(nlag,nraf,forget);  % make running rect AF parms

plag = plagmake(nrad,nphi,nlag);

[ptheta, maxrad] = pthetamake(nrad,nphi,nraf);   % make running polar AF parms

[rectrotr, rectroti] = rectrotmake(nraf,nlag,outdelay);

[req, pheq] = rectopol(nraf,nlag,nrad,nphi);

outct = 0;

lastsigma = ones(1,nphi);

for ii=0:(tlen-1)
    
    xr = zeros(1, slen);
    xi = zeros(1, slen);
    
    if (ii < xlen)
        xr(1:(ii+1)) = fliplr(xr_tmp(1:(ii+1)));
        xi(1:(ii+1)) = fliplr(xi_tmp(1:(ii+1)));
    else
        xr((ii - xlen + 2):(ii + 1)) = fliplr(xr_tmp);
        xi((ii - xlen + 2):(ii + 1)) = fliplr(xi_tmp);
    end
    
    [rectafr, rectafi] = rectaf(xr,xi,nlag,nraf,rar,rai,rarN,raiN,rectafr,rectafi);
    
    if ( rem(ii, tstep) == 0 )	% output t-f slice
        outct = outct + 1;
        
        rectafm2 = rectafr.^2 + rectafi.^2;
        
        polafm2 = polafint(nrad,nphi,nraf,maxrad,nlag,plag,ptheta,rectafm2);
        
        %sigma keeps getting updated. need to pass old value into
        %new one
        
        sigma = sigupdate(nrad,nphi,nits,vol,mu,maxrad,polafm2,lastsigma);
        lastsigma = sigma;
        
        tfslicer = zeros(1, fftlen);
        tfslicei = zeros(1, fftlen);
        
        rtemp  = rectafr .* rectrotr + rectafi .* rectroti;
        rtemp1 = rectafi .* rectrotr - rectafr .* rectroti;
        
        rtemp2 = rectkern(0:(nlag-2),0:(nraf-1),nraf,nphi,req,pheq,sigma);
        
        % Computer first half of time-frequency domain
        tfslicer(1:(nlag-1)) = sum(rtemp(:, 1:(nlag-1)).*rtemp2);
        tfslicei(1:(nlag-1)) = sum(rtemp1(:, 1:(nlag-1)).*rtemp2);
        
        % Second half of TF domain is the first half reversed
        tfslicer((fftlen-nlag+3):(fftlen+1)) = tfslicer((nlag-1):-1:1);
        tfslicei((fftlen-nlag+3):(fftlen+1)) = -tfslicei((nlag-1):-1:1);
        
        % Compute the fft
        % It'd be nice if we could use MATLAB's fft, but I think the
        % custom fft_tfr does some sort of array flipping too
        [tfslicer, tfslicei] = fft_tfr(fftlen,mfft,tfslicer,tfslicei);
        
        itemp = fftlen/2 + fstep;
        j = 1;
        for i=itemp:fstep:(fftlen-1),
            ofp(outct,j) = tfslicer(i+1);
            j = j + 1;
        end
        
        for i=0:fstep:(itemp-1),
            ofp(outct,j) = tfslicer(i+1);
            j = j + 1;
        end
    end
end

% Now print the output
f_axis = 32 * ((-fftlen/2):fstep:((fftlen/2)-fstep)) / fftlen;  % in Hz
t_axis = 0:tstep:(tlen-1);  % in seconds
if length(sig_in_tmp)>200
    ofp1=ofp(130:end-129,:);
    
    ofp1=ofp1';
    ofp2=ofp1(end/2:end,:);
else
    
    ofp2=ofp(66:end-65,end/2+1:end)';
end
ofp2=imresize(ofp2,[256 256]);

tfd=ofp2;

end


function [x,y] = fft_tfr(n,m,x,y)

%***************************************************************/
%		fft.c
%		Douglas L. Jones
%		University of Illinois at Urbana-Champaign
%		January 19, 1992
%
%   fft: in-place radix-2 DIT DFT of a complex input
%
%   input:
%	n:	length of FFT: must be a power of two
%	m:	n = 2**m
%   input/output
%	x:	double array of length n with real part of data
%	y:	double array of length n with imag part of data
%
%   Permission to copy and use this program is granted
%   as long as this header is included.
%***************************************************************/

j = 0;				% bit-reverse
n2 = n/2;
for i=1:(n - 2),
    n1 = n2;
    while (j >= n1)
        j = j - n1;
        n1 = n1/2;
    end
    j = j + n1;
    
    if (i < j)
        t1 = x(i+1);
        x(i+1) = x(j+1);
        x(j+1) = t1;
        t1 = y(i+1);
        y(i+1) = y(j+1);
        y(j+1) = t1;
    end
end

n2 = 1;
for i=0:(m-1),
    n1 = n2;
    n2 = n2 + n2;
    e = -2*pi/n2;
    a = 0;
    
    for j=0:(n1-1),
        c = cos(a);
        s = sin(a);
        a = a + e;
        
        for k=j:n2:(n-1),
            t1 = c*x(k+n1+1) - s*y(k+n1+1);
            t2 = s*x(k+n1+1) + c*y(k+n1+1);
            x(k+n1+1) = x(k+1) - t1;
            y(k+n1+1) = y(k+1) - t2;
            x(k+1) = x(k+1) + t1;
            y(k+1) = y(k+1) + t2;
        end
    end
end
end

function [plag] = plagmake(nrad, nphi, nlag)
% plagmake - make matrix of lags for polar running AF
% G.A. Reina 16 Jan 2007
% Modified from the C code provided by D. L. Jones and R. G. Baraniuk
% "An Adaptive Optimal-Kernel Time-Frequency Representation"
%   by D. L. Jones and R. G. Baraniuk, IEEE Transactions on Signal
%   Processing, Vol. 43, No. 10, pp. 2361--2371, October 1995.

plag = ((sqrt(2)*(nlag-1)* (0:(nrad-1))' ) / nrad) * ...
    sin((pi * (0:(nphi-1)) / nphi));
end



function [ar, ai, arN, aiN, att] = rectamake(nlag, n, forget)
% rectamake(nlag, n, forget, ar, ai, arN, aiN)
% G.A. Reina 16 Jan 2007
% Modified from the C code provided by D. L. Jones and R. G. Baraniuk
% "An Adaptive Optimal-Kernel Time-Frequency Representation"
%   by D. L. Jones and R. G. Baraniuk, IEEE Transactions on Signal
%   Processing, Vol. 43, No. 10, pp. 2361--2371, October 1995.


trig = 2*pi/n;
decay = exp(-forget);

ar = decay*cos(trig*(0:n-1));
ai = decay*sin(trig*(0:n-1));

trigN = 2*pi*(n-(0:(nlag-1)))/n;
decayN = exp(-forget*(n-(0:nlag-1)));


for jj = 0:(n-1)
    
    arN(jj+1, :) = decayN .* cos(jj*trigN);
    aiN(jj+1, :) = decayN .* sin(jj*trigN);
    
end
end


function [ptheta, maxrad] = pthetamake(nrad, nphi, ntheta)
% pthetamake - make matrix of theta indicies for polar samples
% G.A. Reina 16 Jan 2007
% Modified from the C code provided by D. L. Jones and R. G. Baraniuk
% "An Adaptive Optimal-Kernel Time-Frequency Representation"
%   by D. L. Jones and R. G. Baraniuk, IEEE Transactions on Signal
%   Processing, Vol. 43, No. 10, pp. 2361--2371, October 1995.

deltheta = 2*pi/ntheta;

maxrad = ones(1, nphi)*nrad;

for ii = 0:(nphi-1),
    
    for jj = 0:(nrad-1),
        theta = -((pi*sqrt(2)/nrad)*jj)*cos((pi*ii)/nphi);
        
        if (theta > -eps)  % in the original code thiis is 0.0
            rtemp = theta / deltheta;
            if ( rtemp > (ntheta / 2 - 1))
                rtemp = -1;
                if (jj < maxrad(ii+1))
                    maxrad(ii+1) = jj;
                end
            end
        else
            rtemp = (theta + 2*pi) / deltheta;
            if (rtemp < ((ntheta/2) + 1))
                rtemp = -1;
                if (jj < maxrad(ii+1))
                    maxrad(ii+1) = jj;
                end
            end
        end
        ptheta(jj+1, ii+1) = rtemp;
    end
end
end

function [rectrotr,rectroti] = rectrotmake(nraf, nlag, outdelay)
% rectrotmake: make array of rect AF phase shifts
% G.A. Reina 16 Jan 2007
% Modified from the C code provided by D. L. Jones and R. G. Baraniuk
% "An Adaptive Optimal-Kernel Time-Frequency Representation"
%   by D. L. Jones and R. G. Baraniuk, IEEE Transactions on Signal
%   Processing, Vol. 43, No. 10, pp. 2361--2371, October 1995.
twopin = 2*pi/nraf;

half_nraf = floor(nraf /2);

rectrotr = zeros(nraf, nlag);
rectroti = zeros(nraf, nlag);

for i = 0:(nlag-1)
    
    rectrotr(1:half_nraf, i+1) = cos( (twopin*(0:(half_nraf-1)))*(outdelay - i/2.0) );
    rectroti(1:half_nraf, i+1) = sin( (twopin*(0:(half_nraf-1)))*(outdelay - i/2.0) );
    
    rectrotr((half_nraf + 1):nraf, i+1) = ...
        cos( (twopin*(((half_nraf):(nraf - 1))-nraf))*(outdelay - i/2.0 ) );
    
    rectroti((half_nraf + 1):nraf, i+1) = ...
        sin( (twopin*(((half_nraf):(nraf - 1))-nraf))*(outdelay - i/2.0 ) );
    
end

end

function [req, pheq] = rectopol(nraf, nlag, nrad, nphi)
% rectopol: find polar indices corresponding to rect samples
% G.A. Reina 16 Jan 2007
% Modified from the C code provided by D. L. Jones and R. G. Baraniuk
% "An Adaptive Optimal-Kernel Time-Frequency Representation"
%   by D. L. Jones and R. G. Baraniuk, IEEE Transactions on Signal
%   Processing, Vol. 43, No. 10, pp. 2361--2371, October 1995.

deltau = sqrt(pi/(nlag-1));
deltheta = 2*sqrt((nlag-1)*pi)/nraf;
delrad = sqrt(2*pi*(nlag-1))/nrad;
delphi = pi/nphi;

half_nraf = floor(nraf / 2);

req = zeros(nraf, nlag);
pheq = zeros(nraf, nlag);

for jj = 0:(half_nraf-1),
    
    req(jj+1, :) = sqrt(((0:(nlag-1))*deltau).^2 + (jj*deltheta).^2) / delrad;
    pheq(jj+1, 2:end) = (atan((jj*deltheta)./((1:(nlag-1))*deltau)) + pi/2)/delphi;
    
    jt = jj - half_nraf;
    req(jj+1+half_nraf, :) = sqrt( ((0:(nlag-1))*deltau).^2 + (jt*deltheta).^2) / delrad;
    pheq(jj+1+half_nraf, 2:end) = (atan((jt*deltheta)./((1:(nlag-1))*deltau)) + pi/2) / delphi;
    
    
end

end

function polafm2 = polafint(~,nphi,ntheta,maxrad,nlag,plag,ptheta,rectafm2)
%  polafint: interpolate AF on polar grid;
% G.A. Reina 16 Jan 2007
% Modified from the C code provided by D. L. Jones and R. G. Baraniuk
% "An Adaptive Optimal-Kernel Time-Frequency Representation"
%   by D. L. Jones and R. G. Baraniuk, IEEE Transactions on Signal
%   Processing, Vol. 43, No. 10, pp. 2361--2371, October 1995.

half_nphi = floor(nphi / 2);

polafm2 = zeros(max(maxrad), nphi);

for ii = 0:(nphi-1), % for all phi ...
    for jj = 0:(maxrad(ii+1)-1),	% and all radii with |theta| < pi
        
        ilag = floor(plag(jj+1, ii+1));
        rlag = plag(jj+1, ii+1) - ilag;
        
        if (ilag <= (nlag - 2))
            
            itheta = floor(ptheta(jj+1, ii+1));
            rtheta = ptheta(jj+1, ii+1) - itheta;
            
            % Some sort of wrap around going on here. Not quite sure why
            if (ii == (half_nphi))
                
                rtemp =  (rectafm2(itheta+2, ilag+1) ...
                    - rectafm2((nphi - (itheta + 1)), (ilag+1)))*rtheta ...
                    + rectafm2((nphi - (itheta + 1)), (ilag+1));
                
                rtemp1 =  (rectafm2(itheta+2, ilag+2) ...
                    - rectafm2((nphi - (itheta + 1)), (ilag+2)))*rtheta ...
                    + rectafm2((nphi - (itheta + 1)), (ilag+2));
                
                polafm2(jj+1, ii+1) = (rtemp1-rtemp)*rlag + rtemp;
                
            else
                
                itheta1 = itheta + 1;
                if ( itheta1 >= ntheta )
                    itheta1 = 0;
                end
                
                rtemp =  (rectafm2(itheta1+1, ilag+1) ...
                    - rectafm2(itheta+1, ilag+1))*rtheta ...
                    + rectafm2(itheta+1, ilag+1);
                
                rtemp1 =  (rectafm2(itheta1+1, ilag+2)...
                    - rectafm2(itheta+1, ilag+2))*rtheta ...
                    + rectafm2(itheta+1, ilag+2);
                
                polafm2(jj+1, ii+1) = (rtemp1-rtemp)*rlag + rtemp;
            end
            
        end
    end
end
end

function [afr, afi] = rectaf(xr,xi,laglen,freqlen,alphar,alphai,alpharN,alphaiN,afr,afi)
% rectaf: generate running AF on rectangular grid;
%	     negative lags, all DFT frequencies
% G.A. Reina 16 Jan 2007
% Modified from the C code provided by D. L. Jones and R. G. Baraniuk
% "An Adaptive Optimal-Kernel Time-Frequency Representation"
%   by D. L. Jones and R. G. Baraniuk, IEEE Transactions on Signal
%   Processing, Vol. 43, No. 10, pp. 2361--2371, October 1995.

rr = xr(1)*xr(1:laglen) + xi(1)*xi(1:laglen);
ri = xi(1)*xr(1:laglen) - xr(1)*xi(1:laglen);

rrN = xr(freqlen - (0:laglen -1) + 1)*xr(freqlen+1) + xi(freqlen - (0:laglen -1) + 1)*xi(freqlen+1);
riN = xi(freqlen - (0:laglen -1) + 1)*xr(freqlen+1) - xr(freqlen - (0:laglen -1) + 1)*xi(freqlen+1);

for ii = 0:(laglen-1),
    
    temp = ( afr(:, ii+1) .* alphar' - afi(:, ii+1) .* alphai' )  ...
        - ( rrN(ii+1) .* alpharN(:, ii+1) - riN(ii+1) .* alphaiN(:, ii+1) ) ...
        + rr(ii+1);
    
    afi(:, ii+1) = ( afi(:, ii+1).*alphar' + afr(:, ii+1).*alphai' ) ...
        - ( riN(ii+1).*alpharN(:, ii+1) + rrN(ii+1).*alphaiN(:, ii+1) ) ...
        + ri(ii+1);
    
    afr(:, ii+1) = temp;
    
end


end


function kern = rectkern(itau,itheta,~,nphi,req,pheq,sigma)
%   rectkern: generate kernel samples on rectangular grid
% G.A. Reina 16 Jan 2007
% Modified from the C code provided by D. L. Jones and R. G. Baraniuk
% "An Adaptive Optimal-Kernel Time-Frequency Representation"
%   by D. L. Jones and R. G. Baraniuk, IEEE Transactions on Signal
%   Processing, Vol. 43, No. 10, pp. 2361--2371, October 1995.

iphi = floor(pheq(itheta+1, itau + 1));
iphi1 = iphi + 1;

iphi1(iphi1 > (nphi-1)) = 0;

tsigma = sigma(iphi+1) + (pheq(itheta+1, itau+1) - iphi).*(sigma(iphi1+1)-sigma(iphi+1));

%  Tom Polver says on his machine, exp screws up when the argument of
%  the exp function is too large */

kern = exp(- ( req(itheta+1, itau+1) ./ tsigma).^2 );
end


function sigma = sigupdate(~,nphi,nits,vol,mu0,maxrad,polafm2,lastsigma)
%   sigupdate: update RG kernel parameters
% G.A. Reina 16 Jan 2007
% Modified from the C code provided by D. L. Jones and R. G. Baraniuk
% "An Adaptive Optimal-Kernel Time-Frequency Representation"
%   by D. L. Jones and R. G. Baraniuk, IEEE Transactions on Signal
%   Processing, Vol. 43, No. 10, pp. 2361--2371, October 1995.

sigma = lastsigma;

for ii=0:(nits-1),
    gradsum = 0.0;
    gradsum1 = 0.0;
    
    
    for i=0:(nphi-1),
        grad(i+1) = 0.0;
        
        ee1 = exp( - 1.0/(sigma(i+1).^2) );	% use Kaiser's efficient method
        ee2 = 1.0;
        eec = ee1*ee1;
        
        
        for j=1:(maxrad(i+1)-1)
            ee2 = ee1*ee2;
            ee1 = eec*ee1;
            grad(i+1) = grad(i+1) + (j.^3)*ee2*polafm2(j+1, i+1);
        end
        grad(i+1) = grad(i+1)/(sigma(i+1).^3);
        
        gradsum = gradsum + grad(i+1).^2;
        gradsum1 = gradsum1 + sigma(i+1)*grad(i+1);
        
    end
    
    gradsum1 = 2*gradsum1;
    
    if ( gradsum < 0.0000001 )
        gradsum = 0.0000001;
    end
    
    if ( gradsum1 < 0.0000001 )
        gradsum1 = 0.0000001;
    end
    
    mu = ( sqrt(gradsum1.^2 + 4.0*gradsum*vol*mu0) - gradsum1 ) / ( 2.0*gradsum );
    
    sigma = sigma + mu*grad;
    sigma(sigma < 0.5) = 0.5;
    tvol = sum(sigma.^2);
    
    volfac = sqrt(vol/tvol);
    
    sigma = volfac*sigma;
    
end
end







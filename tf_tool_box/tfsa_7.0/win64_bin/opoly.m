function c = opoly(x,y,n)
%
%   opolyfit     OPOLYFIT(x,y,n) finds the n coefficients of a polynomial
%		 formed from the data in row vector x that fits the data
%		 in row vector y in a least-squares sense. Orthogonal
%		 polynomials are used to improve accuracy. See also polyfit.
%
%		 c = opolyfit(x,y,n)
%		 c  ---	coefficient vector, size n
%
%		 References:
%		 G. E. Forsythe, "Generation and use of orthogonal poly-
%		 nomials for data fitting on a digital computer",
%		 J. SIAM, 5(1957), 74-88.
%
%		 P. F. Hultquist, "Numerical Methods for Engineers and
%		 Computer Scientists", Benjamin-Cummings, 1988.
%
%		 Copyright 1992. Gordon	J. Frazer, Signal Processing Research
%		 Laboratory, and Roy J. Hughes, Laboratory for Instrumental and
%		 Developmental Chemistry, QUT, Brisbane, AUSTRALIA, 1992.
%		 Email:	g.frazer@qut.edu.au or	r.hughes@qut.edu.au
n=n+1; % To make it similar to MATLAB polyfit.m

if n<1
 error('polynomial order too small, must be greater than or equal to one');
end
if n+1>length(x)
 error('polynomial order too large for number of data points');
end
% normalise y to improve numerical stability
yscale=0.5/max(abs(y));
yy=yscale*y;
% initialise opoloyfit
gamma_0=length(x);
alpha_0=mean(x);
PC=zeros(n);
PC(1,1)=1;
a=zeros(1,n);
a(1)=mean(yy);
% calculate the	first iteration	manually
PC(2,1:2)=conv([1,-alpha_0],PC(1,1));
gamma_k=sum(polyval(PC(2,1:2),x).*polyval(PC(2,1:2),x));
beta_k=gamma_k/gamma_0;
alpha_k=sum(x.*(polyval(PC(2,1:2),x).*polyval(PC(2,1:2),x)))/gamma_k;
a(2)=sum(yy.*polyval(PC(2,1:2),x))/gamma_k;
% calculate for	the remaining polynomial orders
for k=2:n-1
 PC(k+1,1:k+1)=conv([1,-alpha_k],PC(k,1:k))-beta_k*[0,0,PC(k-1,1:k-1)];
 gamma_km1=gamma_k;
 gamma_k=sum(polyval(PC(k+1,1:k+1),x).*polyval(PC(k+1,1:k+1),x));
 beta_k=gamma_k/gamma_km1;
 alpha_k=sum(x.*(polyval(PC(k+1,1:k+1),x).*polyval(PC(k+1,1:k+1),x)))/gamma_k;
 a(k+1)=sum(yy.*polyval(PC(k+1,1:k+1),x))/gamma_k;
end
% combine the a's to simplify the polynomial
for i=1:n
 PC(i,:)=a(i)*PC(i,:);
end
for i=1:n
 cc(i)=sum(diag(PC,i-n));
end
% unnormalise c	by the y scale factor
c=(1/yscale)*cc;



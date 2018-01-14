%  This program is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation; either version 2 of the License, or
%  (at your option) any later version.
%
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program; if not, write to the Free Software
%  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
%function zakt
%ZAKT	Unit test for the function zak.

%	O. Lemoine - February 1996.

N=256;

% Unitarity of the Zak transform
sig1=fmlin(N,0.1,0.4).*amgauss(N,N/2,N/2); 
sig2=noisecg(N);
DZT1=zak(sig1);
DZT2=zak(sig2);
sp1=sig1.'*conj(sig2);
sp2=sum(sum(DZT1.*conj(DZT2)));
if abs(sp1-sp2)>sqrt(eps),
  error('zak test 1 failed');
end

sig1=noisecu(N); 
sig2=noisecg(N);
DZT1=zak(sig1,32,8);
DZT2=zak(sig2,32,8);
sp1=sig1.'*conj(sig2);
sp2=sum(sum(DZT1.*conj(DZT2)));
if abs(sp1-sp2)>sqrt(eps),
  error('zak test 2 failed');
end

sig1=noisecu(N); 
sig2=noisecg(N);
DZT1=zak(sig1,2,128);
DZT2=zak(sig2,2,128);
sp1=sig1.'*conj(sig2);
sp2=sum(sum(DZT1.*conj(DZT2)));
if abs(sp1-sp2)>sqrt(eps),
  error('zak test 3 failed');
end

% Energy conservation (particular case of unitarity)
sig=noisecg(N);
DZT=zak(sig);
E1=norm(sig)^2;
E2=sum(sum(abs(DZT).^2));
if abs(E1-E2)>sqrt(eps),
  error('zak test 4 failed');
end


N=5*7*3;

% Unitarity of the Zak transform
sig1=fmlin(N,0.1,0.4).*amgauss(N,round(N/2),round(N/2)); 
sig2=noisecg(N);
DZT1=zak(sig1);
DZT2=zak(sig2);
sp1=sig1.'*conj(sig2);
sp2=sum(sum(DZT1.*conj(DZT2)));
if abs(sp1-sp2)>sqrt(eps),
  error('zak test 5 failed');
end

sig1=noisecu(N); 
sig2=noisecg(N);
DZT1=zak(sig1,35,3);
DZT2=zak(sig2,35,3);
sp1=sig1.'*conj(sig2);
sp2=sum(sum(DZT1.*conj(DZT2)));
if abs(sp1-sp2)>sqrt(eps),
  error('zak test 6 failed');
end

sig1=noisecu(N); 
sig2=noisecg(N);
DZT1=zak(sig1,5,21);
DZT2=zak(sig2,5,21);
sp1=sig1.'*conj(sig2);
sp2=sum(sum(DZT1.*conj(DZT2)));
if abs(sp1-sp2)>sqrt(eps),
  error('zak test 7 failed');
end

% Energy conservation (particular case of unitarity)
sig=noisecg(N);
DZT=zak(sig);
E1=norm(sig)^2;
E2=sum(sum(abs(DZT).^2));
if abs(E1-E2)>sqrt(eps),
  error('zak test 8 failed');
end


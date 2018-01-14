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
%function locfreqt
%LOCFREQT Unit test for the function LOCFREQ.

%	O. Lemoine - January 1996.

N=256;

% Test for a complex sinusoid
sig1=fmconst(N);
[fm1,B1]=locfreq(sig1); 
if abs(fm1-.25)>sqrt(eps),
  error('locfreq test 1 failed');
end
if abs(B1)>sqrt(eps),
  error('locfreq test 2 failed');
end

% Test for a real impulse
sig2=real(anapulse(N,N/2));
[fm2,B2]=locfreq(sig2) ;
if abs(fm2)>5e-2,
  error('locfreq test 3 failed');
end
Bth=sqrt(pi*(N^2-1)/3)/N;
if abs(B2-Bth)>sqrt(eps),
  error('locfreq test 4 failed');
end

% Test for a Gaussian window : lower bound of the Heisenber-Gabor
% inequality 
sig3=amgauss(256);
[fm3,B3]=locfreq(sig3);
[tm3,T3]=loctime(sig3); 
if abs(T3*B3-1)>sqrt(eps),
  error('locfreq test 5 failed');
end


N=231;

% Test for a complex sinusoid
sig1=fmconst(N);
[fm1,B1]=locfreq(sig1); 
if abs(fm1-.25)>5e-5,
  error('locfreq test 6 failed');
end
if abs(B1)>1e-1,
  error('locfreq test 7 failed');
end

% Test for a real impulse
sig2=real(anapulse(N,round(N/2)));
[fm2,B2]=locfreq(sig2) ;
if abs(fm2)>5e-2,
  error('locfreq test 8 failed');
end
Bth=sqrt(pi*(N^2-1)/3)/N;
if abs(B2-Bth)>sqrt(eps),
  error('locfreq test 9 failed');
end

% Test for a Gaussian window : lower bound of the Heisenber-Gabor
% inequality 
sig3=amgauss(256);
[fm3,B3]=locfreq(sig3);
[tm3,T3]=loctime(sig3); 
if abs(T3*B3-1)>sqrt(eps),
  error('locfreq test 10 failed');
end


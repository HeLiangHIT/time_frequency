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
%function fmhypt
%FMHYPT	Unit test for the function FMHYP.

%	O. Lemoine - February 1996.

N=256;
t=1:N;

% For a hyperbolic instantaneous frequency, mentionning F0 and C
F0=0.05; C=.3;
[x,iflaw]=fmhyp(N,[F0,C]);
if any(abs(iflaw-(F0+C./t)')>sqrt(eps))~=0,
  error('fmhyp test 1 failed');
end

% For a hyperbolic instantaneous frequency, mentionning P1 and P2
P1=[1,.1]; P2=[200,.4];
[x,iflaw]=fmhyp(N,P1,P2);
if abs(iflaw(P1(1))-P1(2))>sqrt(eps) | abs(iflaw(P2(1))-P2(2))>sqrt(eps),
  error('fmhyp test 2 failed');
end

% For a hyperbolic group delay, mentionning P1 and P2
P1=[10,.45]; P2=[236,.25];
[x,iflaw]=fmhyp(N,P1,P2);
if abs(iflaw(P1(1))-P1(2))>sqrt(eps) | abs(iflaw(P2(1))-P2(2))>sqrt(eps),
  error('fmhyp test 3 failed');
end


N=251;
t=1:N;

% For a hyperbolic instantaneous frequency, mentionning F0 and C
F0=0.05; C=.3;
[x,iflaw]=fmhyp(N,[F0,C]);
if any(abs(iflaw-(F0+C./t)')>sqrt(eps))~=0,
  error('fmhyp test 4 failed');
end

% For a hyperbolic instantaneous frequency, mentionning P1 and P2
P1=[1,.1]; P2=[200,.4];
[x,iflaw]=fmhyp(N,P1,P2);
if abs(iflaw(P1(1))-P1(2))>sqrt(eps) | abs(iflaw(P2(1))-P2(2))>sqrt(eps),
  error('fmhyp test 5 failed');
end

% For a hyperbolic group delay, mentionning P1 and P2
P1=[10,.45]; P2=[236,.25];
[x,iflaw]=fmhyp(N,P1,P2);
if abs(iflaw(P1(1))-P1(2))>sqrt(eps) | abs(iflaw(P2(1))-P2(2))>sqrt(eps),
  error('fmhyp test 6 failed');
end

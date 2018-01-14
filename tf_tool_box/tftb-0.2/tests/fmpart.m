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
%function fmpart
%FMPART	Unit test for the function FMPAR.

%	O. Lemoine - February 1996.

N=256;
t=1:N;

% NARGIN=2
P1=[0.5 -0.007 2.7*10^(-5)];
[x,iflaw]=fmpar(N,P1);

if any(abs(iflaw-(P1(1)+P1(2).*t+P1(3).*t.^2)')>sqrt(eps))~=0,
  error('fmpar test 1 failed');
end

% NARGIN=4
P1=[10 0.4];
P2=[120 0.05];
P3=[246 0.39];
[x,iflaw]=fmpar(N,P1,P2,P3);
if abs(iflaw(P1(1))-P1(2))>sqrt(eps) | abs(iflaw(P2(1))-P2(2))>sqrt(eps) | ...
   abs(iflaw(P3(1))-P3(2))>sqrt(eps),
  error('fmpar test 2 failed');
end

P1=[20 0.13];
P2=[145 0.45];
P3=[226 0.19];
[x,iflaw]=fmpar(N,P1,P2,P3);
if abs(iflaw(P1(1))-P1(2))>sqrt(eps) | abs(iflaw(P2(1))-P2(2))>sqrt(eps) | ...
   abs(iflaw(P3(1))-P3(2))>sqrt(eps),
  error('fmpar test 3 failed');
end


N=251;
t=1:N;

% NARGIN=2
P1=[0.5 -0.007 2.7*10^(-5)];
[x,iflaw]=fmpar(N,P1);

if any(abs(iflaw-(P1(1)+P1(2).*t+P1(3).*t.^2)')>sqrt(eps))~=0,
  error('fmpar test 4 failed');
end

% NARGIN=4
P1=[10 0.4];
P2=[120 0.05];
P3=[246 0.39];
[x,iflaw]=fmpar(N,P1,P2,P3);
if abs(iflaw(P1(1))-P1(2))>sqrt(eps) | abs(iflaw(P2(1))-P2(2))>sqrt(eps) | ...
   abs(iflaw(P3(1))-P3(2))>sqrt(eps),
  error('fmpar test 5 failed');
end

P1=[20 0.13];
P2=[145 0.45];
P3=[226 0.19];
[x,iflaw]=fmpar(N,P1,P2,P3);
if abs(iflaw(P1(1))-P1(2))>sqrt(eps) | abs(iflaw(P2(1))-P2(2))>sqrt(eps) | ...
   abs(iflaw(P3(1))-P3(2))>sqrt(eps),
  error('fmpar test 6 failed');
end

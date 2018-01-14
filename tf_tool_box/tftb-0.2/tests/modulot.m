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
%function modulot
%MODULOT Unit test for the function modulo.

%	O. Lemoine - February 1996.

X=(-100:100);
N=13;
Y=modulo(X,N);

% Test the output values between 1 and N.
errors=find(any(Y<1));
if length(errors)~=0,
  error('modulo test 1 failed');
end

errors=find(any(Y>N));
if length(errors)~=0,
  error('modulo test 2 failed');
end

% Test the identity if X between 1 and N
X=1:N;
Y=modulo(X,N);
errors=find(any(Y-X));
if length(errors)~=0,
  error('modulo test 3 failed');
end

% Test for a vector of complex non-integer values
X=noisecg(300);
N=23.6;
Y=modulo(X,N);
errors=find(any(Y<=0));
if length(errors)~=0,
  error('modulo test 4 failed');
end

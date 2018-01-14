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
%function klaudert
%KLAUDERT Unit test for function KLAUDER.

%	O. Lemoine - March 1996.

N=256;

% Admissibility condition
psi=klauder(N);
if abs(sum(psi))>sqrt(eps),
 error('klauder test 1 failed');
end

% Admissibility condition
psi=klauder(N,100,0.04);
if abs(sum(psi))>sqrt(eps),
 error('klauder test 2 failed');
end

% Admissibility condition
psi=klauder(N,1,0.49);
if abs(sum(psi))>sqrt(eps),
 error('klauder test 3 failed');
end


N=227;

% Admissibility condition
psi=klauder(N);
if abs(sum(psi))>sqrt(eps),
 error('klauder test 4 failed');
end

% Admissibility condition
psi=klauder(N,100,0.04);
if abs(sum(psi))>sqrt(eps),
 error('klauder test 5 failed');
end

% Admissibility condition
psi=klauder(N,1,0.49);
if abs(sum(psi))>sqrt(eps),
 error('klauder test 6 failed');
end

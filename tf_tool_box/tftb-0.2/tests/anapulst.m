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
%function anapulst
%ANAPULST Unit test for the function ANAPULSE.

%	O. Lemoine - February 1996.

N=1024; ti=332;
sig=anapulse(N,ti);
if abs(real(sig(ti))-1)>sqrt(eps), 
 error('anapulse test 1 failed');
elseif sum(real(sig)>sqrt(eps))~=1,
 error('anapulse test 2 failed');
end

N=541;
sig=anapulse(N);
if abs(real(sig(round(N/2)))-1)>sqrt(eps), 
 error('anapulse test 3 failed');
elseif sum(real(sig)>sqrt(eps))~=1,
 error('anapulse test 4 failed');
end

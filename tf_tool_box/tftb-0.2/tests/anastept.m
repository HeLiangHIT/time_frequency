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
%function anastept
%ANASTEPT Unit test for the function ANASTEP.

%	O. Lemoine - February 1996.

N=1024; ti=332;
sig=anastep(N,ti);
if sum(abs(real(sig(ti:N))-1)>sqrt(eps))~=0, 
 error('anastep test 1 failed');
elseif sum(real(sig(1:ti-1))>sqrt(eps))~=0,
 error('anastep test 2 failed');
end

N=541;
sig=anastep(N);
ti=round(N/2);
if sum(abs(real(sig(ti:N))-1)>sqrt(eps))~=0, 
 error('anastep test 1 failed');
elseif sum(real(sig(1:ti-1))>sqrt(eps))~=0,
 error('anastep test 2 failed');
end

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
%function holdert
%HOLDERT Unit test for the function HOLDER.

%	O. Lemoine - August 1996.

N=256;

h=0; t0=N/2;
sig=anasing(N,t0,h);
[tfr,t,f]=tfrscalo(sig,1:N,16,0.01,0.49,2*N);
h0=holder(tfr,f,1,2*N,t0,0);
if abs(h-h0)>1e-2,
 error('holder test 1 failed');
end


h=-0.5; t0=N/2;
sig=anasing(N,t0,h);
[tfr,t,f]=tfrscalo(sig,1:N,16,0.01,0.49,2*N);
h0=holder(tfr,f,1,2*N,t0,0);
if abs(h-h0)>1e-2,
 error('holder test 2 failed');
end



N=211;

h=0; t0=(N-1)/2;
sig=anasing(N,t0,h);
[tfr,t,f]=tfrscalo(sig,1:N,16,0.01,0.49,2*N);
h0=holder(tfr,f,1,2*N,t0,0);
if abs(h-h0)>1e-2,
 error('holder test 3 failed');
end


h=-0.4; t0=(N-1)/2;
sig=anasing(N,t0,h);
[tfr,t,f]=tfrscalo(sig,1:N,16,0.01,0.49,2*N);
h0=holder(tfr,f,1,2*N,t0,0);
if abs(h-h0)>1e-2,
 error('holder test 4 failed');
end


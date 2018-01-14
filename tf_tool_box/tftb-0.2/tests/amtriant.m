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
function amtriant
%AMTRIANT Unit test for the function AMTRIANG.

%	O. Lemoine - February 1996.


N=256; t0=149; T=50; 
sig=amtriang(N,t0,T);
if abs(sig(t0)-1)>sqrt(eps),				% sig(t0)=1
 error('amtriang test 1 failed ');
end
[tm,T1]=loctime(sig);
if abs(T-T1)>=sqrt(1/N),				% width
 error('amtriang test 3 failed ');	
end
dist=1:min([N-t0,t0-1]);
if any(abs(sig(t0-dist)-sig(t0+dist))>sqrt(eps))~=0, 	% symmetry
 error('amtriang test 3 failed ');
end


N=12; t0=5; T=7; 
sig=amtriang(N,t0,T);
if abs(sig(t0)-1)>sqrt(eps),				% sig(t0)=1
 error('amtriang test 4 failed ');
end
[tm,T1]=loctime(sig);
if abs(T-T1)>=sqrt(1/N),				% width
 error('amtriang test 5 failed ');	
end
dist=1:min([N-t0,t0-1]);
if any(abs(sig(t0-dist)-sig(t0+dist))>sqrt(eps))~=0, 	% symmetry
 error('amtriang test 6 failed ');
end


N=535; t0=354; T=101; 
sig=amtriang(N,t0,T);
if abs(sig(t0)-1)>sqrt(eps),				% sig(t0)=1
 error('amtriang test 7 failed ');
end
[tm,T1]=loctime(sig);
if abs(T-T1)>=sqrt(1/N),				% width
 error('amtriang test 8 failed ');	
end
dist=1:min([N-t0,t0-1]);
if any(abs(sig(t0-dist)-sig(t0+dist))>sqrt(eps))~=0, 	% symmetry
 error('amtriang test 9 failed ');
end

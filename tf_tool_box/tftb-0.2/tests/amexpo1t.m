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
function amexpo1t
%AMEXPO1T Unit test for the function AMEXPO1S.

%	O. Lemoine - February 1996.


N=256; t0=32; T=50; 
sig=amexpo1s(N,t0,T);
if abs(sig(t0)-1)>sqrt(eps),			% sig(t0)=1
 error('amexpo1s test 1 failed ');
end
[tm,T1]=loctime(sig);
if abs(T-T1)>=sqrt(1/(N-t0)),				% width
 error('amexpo1s test 2 failed ');
elseif any(abs(sig(1:t0-1))>sqrt(eps))~=0,	% null before t0
 error('amexpo1s test 3 failed ');
end

N=133; t0=28; T=15; 
sig=amexpo1s(N,t0,T);
if abs(sig(t0)-1)>sqrt(eps),			% sig(t0)=1
 error('amexpo1s test 4 failed ');
end
[tm,T1]=loctime(sig);
if abs(T-T1)>=sqrt(1/(N-t0)),			% width
 error('amexpo1s test 5 failed ');
elseif any(abs(sig(1:t0-1))>sqrt(eps))~=0,	% null before t0
 error('amexpo1s test 6 failed ');
end

N=529; t0=409; T=31; 
sig=amexpo1s(N,t0,T);
if abs(sig(t0)-1)>sqrt(eps),			% sig(t0)=1
 error('amexpo1s test 7 failed ');
end
[tm,T1]=loctime(sig);
if abs(T-T1)>=sqrt(1/(N-t0)),			% width
 error('amexpo1s test 8 failed ');
elseif any(abs(sig(1:t0-1))>sqrt(eps))~=0,	% null before t0
 error('amexpo1s test 9 failed ');
end

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
%function fmconstt
%FMCONSTT Unit test for the function FMCONST.

%	F. Auger - December 1995, O. Lemoine - February 1996. 

 N=200;

 [sig iflaw]=fmconst(N);
 if any(abs(iflaw-0.25)>sqrt(eps))~=0 | abs(sig(N/2)-1)>sqrt(eps),
  error('fmconst test 1 failed');
 end;  

 [sig iflaw]=fmconst(N,0.1);
 if any(abs(iflaw-0.1)>sqrt(eps))~=0 | abs(sig(N/2)-1)>sqrt(eps),
  error('fmconst test 2 failed');
 end;

 [sig iflaw]=fmconst(N,0.1,20);
 if any(abs(iflaw-0.1)>sqrt(eps))~=0 | abs(sig(20)-1.0)>sqrt(eps), 
  error('fmconst test 3 failed');
 end;

 [ifl,t]=instfreq(sig);
 if norm(iflaw(t)-ifl)>sqrt(eps), 
  error('fmconst test 4 failed');
 end;


 N=211;
 [sig iflaw]=fmconst(N);
 if any(abs(iflaw-0.25)>sqrt(eps))~=0 | abs(sig(ceil(N/2))-1.0)>sqrt(eps),
  error('fmconst test 5 failed');
 end;  

 [sig iflaw]=fmconst(N,0.1);
 if any(abs(iflaw-0.1)>sqrt(eps))~=0 | abs(sig(ceil(N/2))-1.0)>sqrt(eps),
  error('fmconst test 6 failed');
 end;

 [sig iflaw]=fmconst(N,0.1,20);
 if any(abs(iflaw-0.1)>sqrt(eps))~=0 | abs(sig(20)-1.0)>sqrt(eps), 
  error('fmconst test 7 failed');
 end;
 [ifl,t]=instfreq(sig);
 if norm(iflaw(t)-ifl)>sqrt(eps), 
  error('fmconst test 8 failed');
 end;

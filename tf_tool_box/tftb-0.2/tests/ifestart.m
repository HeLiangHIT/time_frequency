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
%function ifestart
%IFESTART Unit test for the function IFESTAR2.

%	O. Lemoine - August 1996.

N=235; 

% Constant frequency modulation
[sig,ifl]=fmconst(N);
[iflaw,t]=ifestar2(sig);
if any(abs(ifl(t)-iflaw)>sqrt(eps)),
 error('ifestar2 test 1 failed');
end;

[sig,ifl]=fmconst(N,0.01);
[iflaw,t]=ifestar2(sig);
if any(abs(ifl(t)-iflaw)>sqrt(eps)),
 error('ifestar2 test 2 failed');
end;


% Linear frequency modulation
[sig,ifl]=fmlin(N,.05,.45);
[iflaw,t]=ifestar2(sig);
if any(abs(ifl(t)-iflaw)>1e-2),
 error('ifestar2 test 3 failed');
end;


% Sinusoidal frequency modulation
[sig,ifl]=fmsin(N);
[iflaw,t]=ifestar2(sig);
if any(abs(ifl(t)-iflaw)>1e-1),
 error('ifestar2 test 4 failed');
end;

[sig,ifl]=fmsin(N,0.03,0.35,2*N);
[iflaw,t]=ifestar2(sig);
if any(abs(ifl(t)-iflaw)>1e-2),
 error('ifestar2 test 5 failed');
end;


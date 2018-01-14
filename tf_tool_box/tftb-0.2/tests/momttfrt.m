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
%function momttfrt
%MOMTTFRT Unit test for the function MOMTTFR.

%	O. Lemoine - March 1996.

N=128;

% For a perfect line
[sig,ifl]=fmlin(N);
tfr=tfrideal(ifl);
[fm,B2]=momttfr(tfr,'type2'); 
fmth=linspace(0,0.5-1/(2*N),N);
if any(abs(fm-fmth')>sqrt(eps)),
  error('momttfr test 1 failed');
elseif any(abs(B2)>sqrt(eps)),
  error('momttfr test 2 failed');
end

% For a sinusoid
[sig,ifl]=fmsin(N);
tfr=tfrideal(ifl);
[fm,B2]=momttfr(tfr,'type2'); 
if any(abs(fm-ifl)>sqrt(1/N)),
  error('momttfr test 3 failed');
elseif any(abs(B2)>sqrt(eps)),
  error('momttfr test 4 failed');
end

% For a signal composed of 3 iflaws
[sig1,ifl1]=fmlin(N); 
[sig2,ifl2]=fmsin(N);
[sig3,ifl3]=fmhyp(N,[1 0.5],[N/2 0.1]); 
tfr=tfrideal([ifl1;ifl2;ifl3]); 
[fm,B2]=momttfr(tfr,'type2'); 
if any(abs(fm-[ifl1;ifl2;ifl3])>sqrt(1/N)),
  error('momttfr test 5 failed');
elseif any(abs(B2)>sqrt(eps)),
  error('momttfr test 6 failed');
end


N=111;

% For a perfect line
[sig,ifl]=fmlin(N);
tfr=tfrideal(ifl);
[fm,B2]=momttfr(tfr,'type2'); 
fmth=linspace(0,0.5-1/(2*N),N);
if any(abs(fm-fmth')>sqrt(eps)),
  error('momttfr test 7 failed');
elseif any(abs(B2)>sqrt(eps)),
  error('momttfr test 8 failed');
end

% For a sinusoid
[sig,ifl]=fmsin(N);
tfr=tfrideal(ifl);
[fm,B2]=momttfr(tfr,'type2'); 
if any(abs(fm-ifl)>sqrt(1/N)),
  error('momttfr test 9 failed');
elseif any(abs(B2)>sqrt(eps)),
  error('momttfr test 10 failed');
end

% For a signal composed of 3 iflaws
[sig1,ifl1]=fmlin(N); 
[sig2,ifl2]=fmsin(N);
[sig3,ifl3]=fmhyp(N,[1 0.5],[N/2 0.1]); 
tfr=tfrideal([ifl1;ifl2;ifl3]); 
[fm,B2]=momttfr(tfr,'type2'); 
if any(abs(fm-[ifl1;ifl2;ifl3])>sqrt(1/N)),
  error('momttfr test 11 failed');
elseif any(abs(B2)>sqrt(eps)),
  error('momttfr test 12 failed');
end

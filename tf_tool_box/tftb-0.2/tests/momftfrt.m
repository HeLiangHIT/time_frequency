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
%function momftfrt
%MOMFTFRT Unit test for the function MOMFTFR.

%	O. Lemoine - March 1996.

N=128;

% For a perfect line
[sig,ifl]=fmlin(N);
tfr=tfrideal(ifl);
[tm,D2]=momftfr(tfr); 
tmth=(1:N);
if any(abs(tm-tmth')>sqrt(eps)),
  error('momftfr test 1 failed');
elseif any(abs(D2)>sqrt(eps)),
  error('momftfr test 2 failed');
end

% For a sinusoid
[sig,ifl]=fmsin(N,0,.5,N*2,1,0);
tfr=tfrideal(ifl);
[tm,D2]=momftfr(tfr'); 
tmth=round(ifl*2*(N-1))+1;
if any(abs(tm-tmth)>sqrt(1/N)),
  error('momftfr test 3 failed');
elseif any(abs(D2)>sqrt(eps)),
  error('momftfr test 4 failed');
end


N=117;

% For a perfect line
[sig,ifl]=fmlin(N);
tfr=tfrideal(ifl);
[tm,D2]=momftfr(tfr); 
tmth=(1:N);
if any(abs(tm-tmth')>sqrt(eps)),
  error('momftfr test 5 failed');
elseif any(abs(D2)>sqrt(eps)),
  error('momftfr test 6 failed');
end

% For a sinusoid
[sig,ifl]=fmsin(N,0,.5,N*2,1,0);
tfr=tfrideal(ifl);
[tm,D2]=momftfr(tfr'); 
tmth=round(ifl*2*(N-1))+1;
if any(abs(tm-tmth)>sqrt(1/N)),
  error('momftfr test 7 failed');
elseif any(abs(D2)>sqrt(eps)),
  error('momftfr test 8 failed');
end


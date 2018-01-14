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
%function tfrrspt
%TFRRSPT Unit test for the function TFRRSP.

%	F. Auger - December 1995, O. Lemoine - April 1996. 


N=128;

% Reality of the TFR
sig=noisecg(N);
[tfr,rtfr]=tfrrsp(sig);
if sum(any(abs(imag(rtfr))>sqrt(eps)))~=0,
 error('tfrrsp test 1 failed');
end


% Energy conservation
sig=fmlin(N);
[tfr,rtfr]=tfrrsp(sig);
Es=norm(sig)^2;
Etfr=sum(mean(rtfr));
if abs(Es-Etfr)>sqrt(eps),
 error('tfrrsp test 2 failed');
end


% Positivity
if any(any(rtfr<0)),
 error('tfrrsp test 3 failed');
end


% time localization
t0=30; sig=((1:N)'==t0);
[tfr,rtfr]=tfrrsp(sig);
[ik,jk]=find(abs(rtfr)>sqrt(eps));
if any(jk~=t0)|any(ik'-(1:N)),
 error('tfrrsp test 4 failed');
end;


% frequency localization
f0=30;
sig=fmconst(N+6,f0/N);
[tfr rtfr]=tfrrsp(sig,N/2+2,N,tftb_window(N+1,'rect'));
if any(find(rtfr>max(rtfr)/N)~=f0+1)|(abs(mean(rtfr)-1.0)>sqrt(eps)),
 error('tfrrsp test 5 failed');
end;


N=123;

% Reality of the TFR
sig=noisecg(N);
[tfr,rtfr]=tfrrsp(sig);
if sum(any(abs(imag(rtfr))>sqrt(eps)))~=0,
 error('tfrrsp test 6 failed');
end


% Energy conservation
sig=fmlin(N);
[tfr,rtfr]=tfrrsp(sig);
Es=norm(sig)^2;
Etfr=sum(mean(rtfr));
if abs(Es-Etfr)>sqrt(eps),
 error('tfrrsp test 7 failed');
end


% Positivity
if any(any(rtfr<0)),
 error('tfrrsp test 8 failed');
end


% time localization
t0=30; sig=((1:N)'==t0);
[tfr,rtfr]=tfrrsp(sig);
[ik,jk]=find(abs(rtfr)>sqrt(eps));
if any(jk~=t0)|any(ik'-(1:N)),
 error('tfrrsp test 9 failed');
end;


% frequency localization
f0=30;
sig=fmconst(N+6,f0/N);
[tfr rtfr]=tfrrsp(sig,round(N/2)+2,N,tftb_window(N,'rect'));
if any(find(rtfr>max(rtfr)/N)~=f0+1)|(abs(mean(rtfr)-1.0)>sqrt(eps)),
 error('tfrrsp test 10 failed');
end;


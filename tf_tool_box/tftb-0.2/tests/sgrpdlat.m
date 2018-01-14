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
%function sgrpdlat
%SGRPDLAT Unit test for the function SGRPDLAY.

%	O. Lemoine - September 1996.


N=256; 

% Pulse
sig=anapulse(N);
f=linspace(0,0.5,N);
gd=sgrpdlay(sig,f);
if any(abs(gd-N/2)>sqrt(eps)),
 error('sgrpdlay test 1 failed');
end;


% Linear frequency modulation
[sig,ifl]=fmlin(N,0.05,.45);
fnorm=linspace(0.05,0.45,N);
gd=sgrpdlay(sig,fnorm)/N;
gd2=interp1(ifl,1:N,fnorm)/N;
gd2=gd2(:);
if any(abs(gd(1:N-2)-gd2(1:N-2))>5e-2),
 error('sgrpdlay test 2 failed');
end;
gd2=reshape(gd2,1,N);

% Power law group delay
[sig,gpd,f]=gdpower(N,1/2);
fnorm=linspace(0.01,0.45,108);
fnorm=fnorm(2:108);
gd=sgrpdlay(sig,fnorm);
if any(abs(gd-gpd(4:110)')/N>5e-2),
 error('sgrpdlay test 3 failed');
end;


N=237; 

% Pulse
sig=anapulse(N);
f=linspace(0,0.5,N);
gd=sgrpdlay(sig,f);
if any(abs(gd-round(N/2))>sqrt(eps)),
 error('sgrpdlay test 4 failed');
end;


% Linear frequency modulation
[sig,ifl]=fmlin(N,0.05,.45);
fnorm=linspace(0.05,0.45,N);
gd=sgrpdlay(sig,fnorm)/N;
gd2=interp1(ifl,1:N,fnorm)/N;
gd2=gd2(:);
if any(abs(gd(2:N-6)-gd2(2:N-6))>5e-2),
 error('sgrpdlay test 5 failed');
end;
gd2=reshape(gd2,1,N);

% Power law group delay
[sig,gpd,f]=gdpower(N,1/2);
fnorm=linspace(0.01,0.45,108);
fnorm=fnorm(2:108);
gd=sgrpdlay(sig,fnorm);
if any(abs(gd-gpd(4:110)')/N>5e-2),
 error('sgrpdlay test 6 failed');
end;


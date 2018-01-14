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
%function gdpowert
%GDPOWERT Unit test for the function GDPOWER.

%	O. Lemoine - August 1996.

 
N=256;

% K=1 : constant group delay
[sig,gd]=gdpower(N,1);
t0=N; t=(1:N);
if any(gd~=t0),
 error('gdpower test 1 failed');
end
if any(sig(t~=t0)>sqrt(eps)),
 error('gdpower test 2 failed');
end

% K=2 : linear group delay
[sig,gd]=gdpower(N,2);
ifl=instfreq(sig);
[s,iflaw]=fmlin(N);
if any(abs(ifl(3:N-2)-iflaw(3:N-2))>5e-2),
 error('gdpower test 3 failed');
end

% K=1/2 
[sig,gpd]=gdpower(N,1/2);
fnorm=linspace(0.01,0.45,108);
fnorm=fnorm(2:108);
gd=sgrpdlay(sig,fnorm);
if any(abs(gd-gpd(4:110)')/N>5e-2),
 error('gdpower test 4 failed');
end;

% K=0 
[sig,gpd]=gdpower(N,0);
fnorm=linspace(0.01,0.45,108);
fnorm=fnorm(2:108);
gd=sgrpdlay(sig,fnorm);
if any(abs(gd-gpd(4:110)')/N>5e-2),
 error('gdpower test 5 failed');
end;

% K=-1 
[sig,gpd]=gdpower(N,-1);
fnorm=linspace(0.01,0.45,108);
fnorm=fnorm(2:108);
gd=sgrpdlay(sig,fnorm);
if any(abs(gd-gpd(4:110)')/N>5e-2),
 error('gdpower test 6 failed');
end;


N=221;

% K=1 : constant group delay
[sig,gd]=gdpower(N,1);
t0=N; t=(1:N);
if any(gd~=t0),
 error('gdpower test 7 failed');
end
if any(sig(t~=t0)>sqrt(eps)),
 error('gdpower test 8 failed');
end

% K=2 : linear group delay
[sig,gd]=gdpower(N,2);
ifl=instfreq(sig);
[s,iflaw]=fmlin(N);
if any(abs(ifl(5:N-2)-iflaw(5:N-2))>5e-2),
 error('gdpower test 9 failed');
end

% K=1/2 
[sig,gpd]=gdpower(N,1/2);
fnorm=linspace(0.01,0.45,108);
fnorm=fnorm(2:108);
gd=sgrpdlay(sig,fnorm);
if any(abs(gd-gpd(4:110)')/N>5e-2),
 error('gdpower test 10 failed');
end;

% K=0 
[sig,gpd]=gdpower(N,0);
fnorm=linspace(0.01,0.45,108);
fnorm=fnorm(2:108);
gd=sgrpdlay(sig,fnorm);
if any(abs(gd-gpd(4:110)')/N>5e-2),
 error('gdpower test 11 failed');
end;

% K=-1 
[sig,gpd]=gdpower(N,-1);
fnorm=linspace(0.01,0.45,108);
fnorm=fnorm(2:108);
gd=sgrpdlay(sig,fnorm);
if any(abs(gd-gpd(4:110)')/N>5e-2),
 error('gdpower test 12 failed');
end;

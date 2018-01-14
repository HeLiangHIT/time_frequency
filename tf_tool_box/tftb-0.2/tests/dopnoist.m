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
%function dopnoist
%DOPNOIST Unit test for the function DOPNOISE.

%	O. Lemoine - March 1996.

N=128; Fs=100; D=12; 

% The only value we can test is iflaw since y is a random variable.

% Pure tone for a fixed target
F0=25; V=0;
[y,iflaw]=dopnoise(N,Fs,F0,D,V);
d=abs(iflaw-iflaw(1));
if sum(any(d>sqrt(eps)))~=0,
 error('dopnoise test 1 failed');
end;

% Null signal for a non-emitting target
F0=0; V=50;
[y,iflaw]=dopnoise(N,Fs,F0,D,V);
d=abs(iflaw-iflaw(1));
if sum(any(d>sqrt(eps)))~=0,
 error('dopnoise test 2 failed');
end;


N=111; Fs=51; D=9; 

% The only value we can test is iflaw since y is a random variable.

% Pure tone for a fixed target
F0=12; V=0;
[y,iflaw]=dopnoise(N,Fs,F0,D,V);
d=abs(iflaw-iflaw(1));
if sum(any(d>sqrt(eps)))~=0,
 error('dopnoise test 3 failed');
end;

% Null signal for a non-emitting target
F0=0; V=51;
[y,iflaw]=dopnoise(N,Fs,F0,D,V);
d=abs(iflaw-iflaw(1));
if sum(any(d>sqrt(eps)))~=0,
 error('dopnoise test 4 failed');
end;

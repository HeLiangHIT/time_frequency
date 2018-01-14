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
%function anafskt
%ANAFSKT Unit test for the function ANAFSK.

%	O. Lemoine - February 1996.

N=256;

% Output frequency law
% At each frequency shift, on point of the iflaw is moved 
Nbf=10; Nc=32;
[signal,ifreq]=anafsk(N,Nc,Nbf);
iflaw=instfreq(signal);
if sum(abs(iflaw-ifreq(2:N-1))>sqrt(eps))>ceil((N-Nc)/Nc),
  error('anafsk test 1 failed');
end

Nbf=5; Nc=41;
[signal,ifreq]=anafsk(N,Nc,Nbf);
iflaw=instfreq(signal);
if sum(abs(iflaw-ifreq(2:N-1))>sqrt(eps))>ceil((N-Nc)/Nc),
  error('anafsk test 2 failed');
end

Nbf=15; Nc=57;
[signal,ifreq]=anafsk(N,Nc,Nbf);
iflaw=instfreq(signal);
if sum(abs(iflaw-ifreq(2:N-1))>sqrt(eps))>ceil((N-Nc)/Nc),
  error('anafsk test 3 failed');
end

% Output amplitude
Nbf=22; Nc=26;
[signal,ifreq]=anafsk(N,Nc,Nbf);
if any(abs(abs(signal)-1)>sqrt(eps))~=0,
  error('anafsk test 4 failed');
end

Nbf=3; Nc=37;
[signal,ifreq]=anafsk(N,Nc,Nbf);
if any(abs(abs(signal)-1)>sqrt(eps))~=0,
  error('anafsk test 5 failed');
end

Nbf=7; Nc=12;
[signal,ifreq]=anafsk(N,Nc,Nbf);
if any(abs(abs(signal)-1)>sqrt(eps))~=0,
  error('anafsk test 6 failed');
end

N=211;

% Output frequency law
% At each frequency shift, on point of the iflaw is moved 
Nbf=10; Nc=32;
[signal,ifreq]=anafsk(N,Nc,Nbf);
iflaw=instfreq(signal);
if sum(abs(iflaw-ifreq(2:N-1))>sqrt(eps))>ceil((N-Nc)/Nc),
  error('anafsk test 7 failed');
end

Nbf=5; Nc=41;
[signal,ifreq]=anafsk(N,Nc,Nbf);
iflaw=instfreq(signal);
if sum(abs(iflaw-ifreq(2:N-1))>sqrt(eps))>ceil((N-Nc)/Nc),
  error('anafsk test 8 failed');
end

Nbf=15; Nc=57;
[signal,ifreq]=anafsk(N,Nc,Nbf);
iflaw=instfreq(signal);
if sum(abs(iflaw-ifreq(2:N-1))>sqrt(eps))>ceil((N-Nc)/Nc),
  error('anafsk test 9 failed');
end

% Output amplitude
Nbf=22; Nc=26;
[signal,ifreq]=anafsk(N,Nc,Nbf);
if any(abs(abs(signal)-1)>sqrt(eps))~=0,
  error('anafsk test 10 failed');
end

Nbf=3; Nc=37;
[signal,ifreq]=anafsk(N,Nc,Nbf);
if any(abs(abs(signal)-1)>sqrt(eps))~=0,
  error('anafsk test 11 failed');
end

Nbf=7; Nc=12;
[signal,ifreq]=anafsk(N,Nc,Nbf);
if any(abs(abs(signal)-1)>sqrt(eps))~=0,
  error('anafsk test 12 failed');
end

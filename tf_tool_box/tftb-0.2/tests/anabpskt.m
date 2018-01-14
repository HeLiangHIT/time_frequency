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
%function anabpskt
%ANABPSKT Unit test for the function ANABPSK.

%	O. Lemoine - February 1996.

N=256;

% Output frequency law
% At each frequency shift, two points of the iflaw are moved 
f0=0.05; Nc=32;
[signal,am]=anabpsk(N,Nc,f0);
iflaw=instfreq(signal);
if sum(abs(iflaw-f0*ones(N-2,1))>sqrt(eps))>ceil(2*(N-Nc)/Nc),
  error('anabpsk test 1 failed');
end

f0=0.31; Nc=17;
[signal,ifreq]=anabpsk(N,Nc,f0);
iflaw=instfreq(signal);
if sum(abs(iflaw-f0*ones(N-2,1))>sqrt(eps))>ceil(2*(N-Nc)/Nc),
  error('anabpsk test 2 failed');
end

f0=0.48; Nc=8;
[signal,ifreq]=anabpsk(N,Nc,f0);
iflaw=instfreq(signal);
if sum(abs(iflaw-f0*ones(N-2,1))>sqrt(eps))>ceil(2*(N-Nc)/Nc),
  error('anabpsk test 3 failed');
end


% Output amplitude
f0=0.01; Nc=26;
[signal,am]=anabpsk(N,Nc,f0);
if any(abs(am)-1)~=0,
  error('anabpsk test 4 failed');
end

f0=0.17; Nc=4;
[signal,am]=anabpsk(N,Nc,f0);
if any(abs(am)-1)~=0,
  error('anabpsk test 5 failed');
end

f0=0.43; Nc=43;
[signal,am]=anabpsk(N,Nc,f0);
if any(abs(am)-1)~=0,
  error('anabpsk test 6 failed');
end


N=221;

% Output frequency law
% At each frequency shift, two points of the iflaw are moved 
f0=0.05; Nc=32;
[signal,am]=anabpsk(N,Nc,f0);
iflaw=instfreq(signal);
if sum(abs(iflaw-f0*ones(N-2,1))>sqrt(eps))>ceil(2*(N-Nc)/Nc),
  error('anabpsk test 7 failed');
end

f0=0.31; Nc=17;
[signal,ifreq]=anabpsk(N,Nc,f0);
iflaw=instfreq(signal);
if sum(abs(iflaw-f0*ones(N-2,1))>sqrt(eps))>ceil(2*(N-Nc)/Nc),
  error('anabpsk test 8 failed');
end

f0=0.48; Nc=8;
[signal,ifreq]=anabpsk(N,Nc,f0);
iflaw=instfreq(signal);
if sum(abs(iflaw-f0*ones(N-2,1))>sqrt(eps))>ceil(2*(N-Nc)/Nc),
  error('anabpsk test 9 failed');
end


% Output amplitude
f0=0.01; Nc=26;
[signal,am]=anabpsk(N,Nc,f0);
if any(abs(am)-1)~=0,
  error('anabpsk test 10 failed');
end

f0=0.17; Nc=4;
[signal,am]=anabpsk(N,Nc,f0);
if any(abs(am)-1)~=0,
  error('anabpsk test 11 failed');
end

f0=0.43; Nc=43;
[signal,am]=anabpsk(N,Nc,f0);
if any(abs(am)-1)~=0,
  error('anabpsk test 12 failed');
end

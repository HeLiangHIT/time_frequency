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
%function anaaskt
%ANAASKT Unit test for the function ANAASK.

%	O. Lemoine - February 1996.

N=256;

% Output frequency law
f0=0.02;
[signal,am]=anaask(N,32,f0);
iflaw=instfreq(signal);
if any(abs(iflaw-f0*ones(N-2,1))>sqrt(eps))~=0,
  error('anaask test 1 failed');
end

f0=0.25;
[signal,am]=anaask(N,41,f0);
iflaw=instfreq(signal);
if any(abs(iflaw-f0*ones(N-2,1))>sqrt(eps))~=0,
  error('anaask test 2 failed');
end

f0=0.49;
[signal,am]=anaask(N,57,f0);
iflaw=instfreq(signal);
if any(abs(iflaw-f0*ones(N-2,1))>sqrt(eps))~=0,
  error('anaask test 3 failed');
end

% Output amplitude
f0=0.01;
[signal,am]=anaask(N,26,f0);
if any(am>1)~=0|any(am<0)~=0,
  error('anaask test 4 failed');
end

f0=0.17;
[signal,am]=anaask(N,37,f0);
if any(am>1)~=0|any(am<0)~=0,
  error('anaask test 5 failed');
end

f0=0.43;
[signal,am]=anaask(N,12,f0);
if any(am>1)~=0|any(am<0)~=0,
  error('anaask test 6 failed');
end

N=221; 

% Output frequency law
f0=0.02;
[signal,am]=anaask(N,32,f0);
iflaw=instfreq(signal);
if any(abs(iflaw-f0*ones(N-2,1))>sqrt(eps))~=0,
  error('anaask test 7 failed');
end

f0=0.25;
[signal,am]=anaask(N,41,f0);
iflaw=instfreq(signal);
if any(abs(iflaw-f0*ones(N-2,1))>sqrt(eps))~=0,
  error('anaask test 8 failed');
end

f0=0.49;
[signal,am]=anaask(N,57,f0);
iflaw=instfreq(signal);
if any(abs(iflaw-f0*ones(N-2,1))>sqrt(eps))~=0,
  error('anaask test 9 failed');
end

% Output amplitude
f0=0.01;
[signal,am]=anaask(N,26,f0);
if any(am>1)~=0|any(am<0)~=0,
  error('anaask test 10 failed');
end

f0=0.17;
[signal,am]=anaask(N,37,f0);
if any(am>1)~=0|any(am<0)~=0,
  error('anaask test 11 failed');
end

f0=0.43;
[signal,am]=anaask(N,12,f0);
if any(am>1)~=0|any(am<0)~=0,
  error('anaask test 12 failed');
end

N=221; 

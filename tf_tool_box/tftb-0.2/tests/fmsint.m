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
%function fmsint
%FMSINT	Unit test for the function FMSIN.

%	O. Lemoine - February 1996. 

 N=200;

 [sig iflaw]=fmsin(N);
 Min=min(iflaw); Max=max(iflaw);
 if abs(Min-0.05)>sqrt(eps) | abs(Max-0.45)>sqrt(eps),
  error('fmsin test 1 failed');
 end;  
 dsp=abs(fft(iflaw-mean(iflaw))).^2; Max=max(dsp);
 if sum(dsp>sqrt(eps))~=2 | abs(dsp(round(1+(N-2)/N))-Max)>sqrt(eps),
  error('fmsin test 2 failed');
 end;  
  
 fmin=0.13; fmax=0.41; T=N/10;
 [sig iflaw]=fmsin(N,fmin,fmax,T);
 Min=min(iflaw); Max=max(iflaw);
 if abs(Min-fmin)>1/T | abs(Max-fmax)>1/T,
  error('fmsin test 3 failed');
 end;  
 dsp=abs(fft(iflaw-mean(iflaw))).^2; Max=max(dsp);
 if sum(dsp>sqrt(eps))~=2 | abs(dsp(round(1+(N-2)/T))-Max)>sqrt(eps),
  error('fmsin test 4 failed');
 end;  
  
 fmin=0.04; fmax=0.38; T=N/5; t0=10; f0=0.1; pm1=-1;
 [sig iflaw]=fmsin(N,fmin,fmax,T,t0,f0,pm1);
 Min=min(iflaw); Max=max(iflaw);
 if abs(Min-fmin)>1/T | abs(Max-fmax)>1/T,
  error('fmsin test 5 failed');
 elseif abs(iflaw(t0)-f0)>sqrt(eps),
  error('fmsin test 6 failed');
 end;  
 dsp=abs(fft(iflaw-mean(iflaw))).^2; Max=max(dsp);
 if sum(dsp>sqrt(eps))~=2 | abs(dsp(round(1+(N-2)/T))-Max)>sqrt(eps),
  error('fmsin test 7 failed');
 end;  
 if iflaw(2)>iflaw(1),
  error('fmsin test 8 failed');
 end


 N=211;

 [sig iflaw]=fmsin(N);
 Min=min(iflaw); Max=max(iflaw);
 if abs(Min-0.05)>1e-5 | abs(Max-0.45)>1e-5,
  error('fmsin test 9 failed');
 end;  
 dsp=abs(fft(iflaw-mean(iflaw))).^2; Max=max(dsp);
 if sum(dsp>sqrt(eps))~=2 | abs(dsp(round(1+(N-2)/N))-Max)>sqrt(eps),
  error('fmsin test 10 failed');
 end;  
  
 fmin=0.13; fmax=0.41; T=N/10;
 [sig iflaw]=fmsin(N,fmin,fmax,T);
 Min=min(iflaw); Max=max(iflaw);
 if abs(Min-fmin)>1/T | abs(Max-fmax)>1/T,
  error('fmsin test 11 failed');
 end;  
 dsp=abs(fft(iflaw-mean(iflaw))).^2; Max=max(dsp);
 if sum(dsp>sqrt(eps))~=2 | abs(dsp(round(1+(N-2)/T))-Max)>sqrt(eps),
  error('fmsin test 12 failed');
 end;  
  
 fmin=0.04; fmax=0.38; T=N/5; t0=10; f0=0.1; pm1=-1;
 [sig iflaw]=fmsin(N,fmin,fmax,T,t0,f0,pm1);
 Min=min(iflaw); Max=max(iflaw);
 if abs(Min-fmin)>1/T | abs(Max-fmax)>1/T,
  error('fmsin test 13 failed');
 elseif abs(iflaw(t0)-f0)>sqrt(eps),
  error('fmsin test 14 failed');
 end;  
 dsp=abs(fft(iflaw-mean(iflaw))).^2; Max=max(dsp);
 if sum(dsp>sqrt(eps))~=2 | abs(dsp(round(1+(N-2)/T))-Max)>sqrt(eps),
  error('fmsin test 15 failed');
 end;  
 if iflaw(2)>iflaw(1),
  error('fmsin test 16 failed');
 end
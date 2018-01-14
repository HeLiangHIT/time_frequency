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
%function ambifunt
%AMBIFUNT Unit test for the function ambifunb.

%	O. Lemoine - December 1995.
%	F. Auger - February 1996.

N=128; 

% Ambiguity function of a pulse
sig=((1:N)'==40); 
amb=ambifunb(sig);
[ik,jk]=find(amb~=0.0);
if any(jk~=N/2)|any(ik'-(1:N)),
 error('ambifunb test 1 failed');
end;

% Ambiguity function of a sine wave
sig=fmconst(N,0.2);
amb=ambifunb(sig);
[a b]=max(amb);
if any(b-odd(N/2)*ones(1,N-1)),
 error('ambifunb test 2 failed');
end;

% Energy 
sig=noisecg(N);
amb=ambifunb(sig);
if abs(abs(amb(odd(N/2),N/2))-norm(sig)^2)>sqrt(eps),
 error('ambifunb test 3 failed');
end;

% Link with the Wigner-Ville distribution
sig=fmlin(N);
amb=ambifunb(sig);
amb=amb([(N+rem(N,2))/2+1:N 1:(N+rem(N,2))/2],:);
ambi=ifft(amb).';
tdr=zeros(N); 		% Time-delay representation
tdr(1:N/2,:)=ambi(N/2:N-1,:);
tdr(N:-1:N/2+2,:)=ambi(N/2-1:-1:1,:);
wvd1=real(fft(tdr));
wvd2=tfrwv(sig);
errors=max(max(abs(wvd1-wvd2)));
if errors>sqrt(eps),
 error('ambifunb test 4 failed');
end;
				     

N=111;

% Ambiguity function of a pulse
sig=((1:N)'==40); 
amb=ambifunb(sig);
[ik,jk]=find(amb~=0.0);
if any(jk~=(N+1)/2)|any(ik'-(1:N)),
 error('ambifunb test 5 failed');
end;

% Ambiguity function of a sine wave
sig=fmconst(N,0.2);
amb=ambifunb(sig);
[a b]=max(amb(:,2:N-1));
if any(b-((N+1)/2)*ones(1,N-2)),
 error('ambifunb test 6 failed');
end;

% Energy 
sig=noisecg(N);
amb=ambifunb(sig);
if abs(abs(amb((N+1)/2,(N+1)/2))-norm(sig)^2)>sqrt(eps),
 error('ambifunb test 7 failed');
end;

% Link with the Wigner-Ville distribution
sig=fmlin(N);
amb=ambifunb(sig);
amb=amb([(N+1)/2:N 1:(N-1)/2],:);
ambi=ifft(amb).';
tdr=zeros(N); 		% Time-delay representation
tdr(1:(N+1)/2,:)      = ambi((N+1)/2:N,:);
tdr(N:-1:(N+1)/2+1,:) = ambi((N-1)/2:-1:1,:);
wvd1=real(fft(tdr));
wvd2=tfrwv(sig,1:N,N);
errors=max(max(abs(wvd1-wvd2)));
if errors>sqrt(eps),
 error('ambifunb test 8 failed');
end;

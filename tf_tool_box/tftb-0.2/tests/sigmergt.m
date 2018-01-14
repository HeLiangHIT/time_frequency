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
%function sigmergt
%SIGMERGT Unit test for the function SIGMERGE.

%	O. Lemoine - March 1996.

N=256;

s1=noisecg(N);
s2=amgauss(N);
R=10;
sig=sigmerge(s1,s2,R);
E1=norm(s1)^2;
E2=norm(s2)^2;
h=sqrt(E1/(E2*10^(R/10)));
err=sig-s1-h*s2;
if any(abs(err)>sqrt(eps)),
 error('sigmerge test 1 failed');
end

s1=noisecu(N);
s2=fmlin(N);
R=-2.4;
sig=sigmerge(s1,s2,R);
E1=norm(s1)^2;
E2=norm(s2)^2;
h=sqrt(E1/(E2*10^(R/10)));
err=sig-s1-h*s2;
if any(abs(err)>sqrt(eps)),
 error('sigmerge test 2 failed');
end


N=245;

s1=noisecg(N);
s2=amgauss(N);
R=10;
sig=sigmerge(s1,s2,R);
E1=norm(s1)^2;
E2=norm(s2)^2;
h=sqrt(E1/(E2*10^(R/10)));
err=sig-s1-h*s2;
if any(abs(err)>sqrt(eps)),
 error('sigmerge test 3 failed');
end

s1=noisecu(N);
s2=fmlin(N);
R=-2.4;
sig=sigmerge(s1,s2,R);
E1=norm(s1)^2;
E2=norm(s2)^2;
h=sqrt(E1/(E2*10^(R/10)));
err=sig-s1-h*s2;
if any(abs(err)>sqrt(eps)),
 error('sigmerge test 4 failed');
end

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
%function izakt
%IZAKT	Unit test for the function izak.

%	O. Lemoine - February 1996.

N=256;

% Perfect reconstruction
sig=noisecg(N);
DZT=zak(sig);
sigr=izak(DZT);
errors=find(any(abs(sig-sigr)>sqrt(eps)));
if length(errors)~=0,
  error('izak test 1 failed');
end

sig=noisecg(N);
DZT=zak(sig,8,32);
sigr=izak(DZT);
errors=find(any(abs(sig-sigr)>sqrt(eps)));
if length(errors)~=0,
  error('izak test 2 failed');
end

sig=noisecg(N);
DZT=zak(sig,128,2);
sigr=izak(DZT);
errors=find(any(abs(sig-sigr)>sqrt(eps)));
if length(errors)~=0,
  error('izak test 3 failed');
end


N=315;

% Perfect reconstruction
sig=noisecg(N);
DZT=zak(sig);
sigr=izak(DZT);
errors=find(any(abs(sig-sigr)>sqrt(eps)));
if length(errors)~=0,
  error('izak test 4 failed');
end

sig=noisecg(N);
DZT=zak(sig,9,35);
sigr=izak(DZT);
errors=find(any(abs(sig-sigr)>sqrt(eps)));
if length(errors)~=0,
  error('izak test 5 failed');
end

sig=noisecg(N);
DZT=zak(sig,3,105);
sigr=izak(DZT);
errors=find(any(abs(sig-sigr)>sqrt(eps)));
if length(errors)~=0,
  error('izak test 6 failed');
end


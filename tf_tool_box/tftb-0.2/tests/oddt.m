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
%function oddt
%ODDT 	Unit test for the function ODD.

%	O. Lemoine - August 1996.

N=1000;

X=randn(N,1)*10;

Y=odd(X);

err1=0;
err2=0;

for k=1:N,
 if (rem(Y(k),2)~=1 & rem(Y(k),2)~=-1), 
  err1=1;
 elseif abs(X(k)-Y(k))>1, 
  err2=1;
 end
end

if err1,
 error('odd test 1 failed');
elseif err2,
 error('odd test 2 failed');
end


N=987;

X=randn(N,1)*10;

Y=odd(X);

err1=0;
err2=0;

for k=1:N,
 if (rem(Y(k),2)~=1 & rem(Y(k),2)~=-1), 
  err1=1;
 elseif abs(X(k)-Y(k))>1, 
  err2=1;
 end
end

if err1,
 error('odd test 3 failed');
elseif err2,
 error('odd test 4 failed');
end
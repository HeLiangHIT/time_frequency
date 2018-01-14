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


issig=0;
isspec=0;
iscolorbar=0;

linlogspec=1;
sigenveloppe=0;


layout=issig+isspec*2+iscolorbar*4;
while layout~=4,
 if issig==0, 
  SignalStr= 'display signal';
 else
  SignalStr='remove signal';
 end;
 
 if isspec==0, 
  SpectrumStr= 'display spectrum';
 else
  SpectrumStr='remove spectrum';
 end;
 
 if iscolorbar==0,
  ColorbarStr='display colorbar';
 else
  ColorbarStr='remove colorbar';
 end;

 layout=menu('DISPLAY LAYOUT',...
             SignalStr,...
             SpectrumStr,...
             ColorbarStr,...
             'close');
            
 if layout==1,
  issig=~issig;
  if issig==1,
   sigenveloppe=menu('SIGNAL REPRESENTATION','signal only','signal with enveloppe')-1;
  end; 
 elseif layout==2,
  isspec=~isspec;
  if isspec==1,
   linlogspec=menu('FREQUENCY REPRESENTATION','linear scale','log scale')-1;
  end;
 elseif layout==3,
  iscolorbar=~iscolorbar;
 end;             
end;           





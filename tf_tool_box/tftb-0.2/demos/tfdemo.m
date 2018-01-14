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
%TFDEMO	Demonstrate some of Time-Frequency Toolbox's capabilities.
%	TFDEMO, by itself, presents a menu of demos.

%	O.Lemoine - May 1996.
%	Copyright (c) CNRS.

clg; clear; clc;
TFTBcontinue=1;

while TFTBcontinue==1,
 choice = menu('Time-Frequency Toolbox Demonstrations',...
    'Introduction',...	
    'Non stationary signals', ...
    'Linear time-frequency representations', ...
    'Cohen''s class time-frequency distributions', ...
    'Affine class time-frequency distributions', ...
    'Reassigned time-frequency distributions', ...
    'Post-processing ',...
    'Close');
 
 if choice==1,
  tfdemo1;
 elseif choice==2,
  tfdemo2;
 elseif choice==3,
  tfdemo3;
 elseif choice==4,
  tfdemo4;
 elseif choice==5,
  tfdemo5;
 elseif choice==6,
  tfdemo6;
 elseif choice==7,
  tfdemo7;
 elseif choice==8,
  TFTBcontinue=0; 
 end
end

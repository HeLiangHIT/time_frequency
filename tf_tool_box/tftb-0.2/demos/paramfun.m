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
echo off
%PARAMFUN Figures representing different TFD of the Cohen's class.
%	On the left, the ambiguity plane and the weighting functions ;
%	On the right, the time-frequency distributions.

%	O. Lemoine - February, July 1996. 


if ~exist('paramfun.mat'),
 echo on
 %
 % PARAMFUN does not exist.
 %
 % You haven't created "paramfun.mat". Please run ??? to proceed.
 % The next part of the demo is skipped.
 %
else
load paramfun
Ncont=5;

subplot(321);
contour(dlr([(N+rem(N,2))/2+1:N 1:(N+rem(N,2))/2],:),8); 
xlabel('Delay'); ylabel('Doppler');
title('Wigner-Ville weighting function')
set(gca,'yTickLabel',[])
set(gca,'xTickLabel',[])
hold on
[a,h]=contour(WF1,[1/2],'g');
set(h,'linewidth',2);
hold off

subplot(322);
Max=max(max(tfr1));
levels=linspace(Max/10,Max,Ncont);
contour(tfr1,levels);
xlabel('Time'); ylabel('Frequency');
title('Wigner-Ville distribution')
set(gca,'yTickLabel',[])
set(gca,'xTickLabel',[])

subplot(323);
contour(dlr([(N+rem(N,2))/2+1:N 1:(N+rem(N,2))/2],:),8); 
xlabel('Delay'); ylabel('Doppler');
title('Spectrogram weighting function');
set(gca,'yTickLabel',[])
set(gca,'xTickLabel',[])
hold on
[a,h]=contour(WF2,[1/2],'g');
set(h,'linewidth',2);
hold off

subplot(324);
Max=max(max(tfr2));
levels=linspace(Max/10,Max,Ncont);
contour(tfr2(1:N/2,:),levels);
xlabel('Time'); ylabel('Frequency');
title('Spectrogram')
set(gca,'yTickLabel',[])
set(gca,'xTickLabel',[])

subplot(325);
contour(dlr([(N+rem(N,2))/2+1:N 1:(N+rem(N,2))/2],:),8); 
xlabel('Delay'); ylabel('Doppler');
title('SP-WV weighting function');
set(gca,'yTickLabel',[])
set(gca,'xTickLabel',[])
hold on
[a,h]=contour(WF3,[1/2],'g');
set(h,'linewidth',2);
hold off

subplot(326);
Max=max(max(tfr3));
levels=linspace(Max/10,Max,Ncont);
contour(tfr3,levels);
xlabel('Time'); ylabel('Frequency');
title('Smoothed-pseudo-WVD');
set(gca,'yTickLabel',[])
set(gca,'xTickLabel',[])


figure(2);

subplot(221);
contour(dlr([(N+rem(N,2))/2+1:N 1:(N+rem(N,2))/2],:),8); 
xlabel('Delay'); ylabel('Doppler');
title('Born-Jordan weighting function');
set(gca,'yTickLabel',[])
set(gca,'xTickLabel',[])
hold on
[a,h]=contour(WF4,[1/2],'g');
set(h,'linewidth',2);
hold off

subplot(222);
Max=max(max(tfr4));
levels=linspace(Max/10,Max,Ncont);
contour(tfr4,levels);
xlabel('Time'); ylabel('Frequency');
title('Born-Jordan distribution');
set(gca,'yTickLabel',[])
set(gca,'xTickLabel',[])


subplot(223);
contour(dlr([(N+rem(N,2))/2+1:N 1:(N+rem(N,2))/2],:),8); 
xlabel('Delay'); ylabel('Doppler');
title('CW weighting function');
set(gca,'yTickLabel',[])
set(gca,'xTickLabel',[])
hold on
[a,h]=contour(WF5,[1/2],'g');
set(h,'linewidth',2);
hold off

subplot(224);
Max=max(max(tfr5));
levels=linspace(Max/10,Max,Ncont);
contour(tfr5,levels);
xlabel('Time'); ylabel('Frequency');
title('Choi-Williams distribution');
set(gca,'yTickLabel',[])
set(gca,'xTickLabel',[])
end;

echo on

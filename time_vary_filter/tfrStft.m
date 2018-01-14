function [tfr] = tfrStft(x,N,h)
%% 短时傅立叶变换：[tfr,f] = tfrStft(x,N,h)
% 输入：
%           x: 输入的时域数据，一行或者一列
%           N：输出的频域长度，需要>=0
%           h：可选一行或者一列输入的窗函数，需要注意h(0)=1，否则无法恢复信号。
% 输出：
%           tfr：计算得到的STFT谱
%           f：STFT谱中各个横轴对应的频率值

x = x(:);   xrow = length(x);  t=1:xrow;%参数初始化
if (nargin < 1),    error('At least 1 parameter is required.');  end
if (nargin < 2),    N=xrow;     end;
if (nargin < 3),
    if (N<0),    error('N must be greater than zero.');end;
    hlength=floor(N/4);
    hlength=hlength+1-rem(hlength,2);
    h = tftb_window(hlength);
end
% if (2^nextpow2(N)~=N),    fprintf('For a faster computation, N should be a power of two.\n'); end;
h = h(:); 
hrow=length(h); Lh=(hrow-1)/2;
if (rem(hrow,2)==0),  error('H must be a smoothing window with odd length.');end
% h=h/norm(h);%保证h(0)=1，才能恢复信号

tfr= zeros (N,xrow) ;midN = round(N/2);
for icol=1:xrow,
    ti= t(icol); tau=-min([midN-1,Lh,ti-1]):min([midN-1,Lh,xrow-ti]);
    indices= rem(midN+tau-1,N);
    tfr(indices,icol)=x(ti+tau,1).*conj(h(Lh+1+tau));
    tfr(:,icol)=fft(tfr(:,icol));%计算FFT谱，对每个时刻
end

if (nargout==0),
    tfrqview(abs(tfr).^2,x,t,'tfrstft',h);
end
end
function y=filterDataSafe(x,winLen)
% 在保护数据x两端不变的情况下对数据进行滤波平滑操作
if(nargin<2 || isempty(winLen)) winLen=10; end

w=hamming( floor(winLen*2) ); w=w./sum(w);

x = [x(1)*ones(1,winLen), x, x(end)*ones(1,winLen)];%边缘填充以防止滤波导致的边缘问题

x_mean=mean(x);
y=conv(x-x_mean,w,'same');
y=y+x_mean;
y = y(winLen+1:end - winLen);
end
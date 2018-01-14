function [fc,uc,popt] = fftIflaw2frftIflaw(iflaw,fLen)
% [fc,uc,popt] = fftIflaw2frftIflaw(iflaw,fLen)
%% 把STFT变换的瞬时频率iflaw转换为STFRFT变换的瞬时频率
% 输入iflaw是信号的瞬时频率，fLen是其频率采样点数量
% 输出fc表示信号的瞬时频率，uc表示信号的瞬时分数阶频率，popt是各个点的FRFT最佳阶数
% 需要注意的是这里返回的fc和uc都是理想的频率坐标点，要使用需要将其【取四舍五入】

if max(iflaw)>0.5 %这种情况表明iflaw是整数频率点，先将其归一化到实际数字频率点
    if max(iflaw)>1; iflaw = iflaw/fLen; end
    iflaw(iflaw>0.5) = iflaw(iflaw>0.5)-1;
end

% 根据iflaw获取斜率，进而得到FRFT旋转角度
kgen = diff(iflaw);% IF的导数是斜率k
% kgenl = [kgen(1);kgen];kgenr = [kgen;kgen(end)];
% kgen = (kgenl+kgenr)/2;
%某一个点的斜率是其左斜率和右斜率的均值，其实可以只取kgenl也影响不大。
popt = real(-acot(kgen*fLen)*2/pi);
% poptl = [popt(1);popt];poptr = [popt;popt(end)];
% popt = (poptl+poptr)/2;
popt = [popt(1);popt];%我也不知道为什么，反正这样出错的概率最小

% 根据实际频率点以及相对偏移值
fc = real(iflaw*fLen); 
uc = real(iflaw*fLen .* sin(popt*pi/2));%实际FRFT域频率


end
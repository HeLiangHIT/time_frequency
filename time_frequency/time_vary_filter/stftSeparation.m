function [sigs,tfr,tfrv] = stftSeparation(x,ifs,halfLen,h)
%% 基于短时傅立叶变换时变滤波的信号分离，固定窗长度：[sigs,tfr,tfrv] = stftSeparation(x,ifs,halfLen,h)
% 输入：x：输入信号，是多个分量的叠加
%           ifs：各列是各个分量的瞬时频率，可以是归一化到-0.5到0.5的，也可以是1-N的数字频率。
%           halLen：固定窗长度的窗半长度
%           h：可选一行或者一列输入的窗函数，需要注意h(0)=1，否则无法恢复信号。
% 输出：sigs：输出信号，各列表示一个信号
%           tfr：计算得到的STFT谱
%           tfrv：三维矩阵分别表示各个分量的STFT谱


assert(nargin>=2,'At least 2 parameter is required.');
% 时变滤波时重复边缘的宏控制，为了避免时变滤波边缘衰变设置该参数，可选设置为1或者0
EDGE_REPEAT = 1;%

%参数初始化
x = x(:);   tLen = length(x);  t=1:tLen; %获取时间长度
fLen = min([tLen, 512]);%频域最大分辨率为512
if max(ifs(:))<1; % 频域值在1以下说明是归一化频率，转换为1-fLen之间
    ifs = mod(round(ifs*fLen), fLen)+1; 
end
[tmp,sigN] = size(ifs);%获取信号的数量
assert(tmp ==  tLen,'Input Length of s must be same as ifs.');%错误判断
if ( nargin < 3),
    halfLen = min([fLen, 30]);%时变滤波的最大窗口长度的一半
end
assert(halfLen<length(x)/2,'The max window length must be small than signal length.');
if nargin < 4,
    hlength=floor(fLen/4); hlength=hlength+1-rem(hlength,2); 
    h = tftb_window(hlength);%默认是Hamming
end
% h=h/norm(h);%保证h(0)=1，才能恢复信号
h = h(:); hrow=length(h); Lh=(hrow-1)/2;%窗参数
if (rem(hrow,2)==0),  error('H must be a smoothing window with odd length.');end

tfr= zeros(fLen,tLen) ;midN = round(fLen/2);% TFR参数初始化
sigs = zeros(tLen,sigN);tfrv = zeros(fLen,tLen,sigN);
for it=1:tLen,
    ti= t(it); tau=max([-midN+1,-Lh,-ti+1]):min([midN-1,Lh,tLen-ti]);
    if EDGE_REPEAT
        %taux = [tau(1)*ones(1,tau(end) - abs(tau(1))),tau,tau(end)*ones(1,abs(tau(1))-tau(end))];%重复边缘为边缘值
        taux = [zeros(1,tau(end) - abs(tau(1))), tau,zeros(1,abs(tau(1))-tau(end))];%重复边缘为当前值
        tauh = 1:hlength;%全部重复
        indices= (midN-Lh) : (midN + Lh);%值重复保存
    else
        taux = tau;
        tauh = Lh+1+tau;
        indices= rem(midN+tau-1,fLen)+1;
    end
    % 计算原始STFT
    tfr(indices,it)=x(ti+taux,1).*conj(h(tauh));
    stmp = tfr(:,it);%缓存的信号分量
    tfr(:,it)=fft(stmp);%计算FFT谱，对每个时刻
    %对各个信号时变滤波
    for is = 1:sigN
        %该时刻频谱的滤波
        indrnd = mod(ifs(it,is)-halfLen : ifs(it,is)+halfLen,fLen)+1;
        ftfr = zeros(tLen,1);%缓存数据
        ftfr(indrnd) = tfr(indrnd,it);%频域滤波，频域的矩形窗
        %信号时域值恢复
        st = ifft(ftfr);%滤波后的数据反变换
        sigs(it,is) = st(midN);%加入的数据是中间值，滤波恢复的也得是中间值
        %plot(t,real(stmp),'b.-',t,real(st),'r.-')%调试信号
        tfrv(:,it,is) = ftfr;
    end
end

end


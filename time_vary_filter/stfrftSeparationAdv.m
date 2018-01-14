function [sigs,tfr,tfrv,ucs] = stfrftSeparationAdv(x,ifs,halfLen,h)
%% 基于短时傅立叶变换时变滤波的信号分离，自适应窗长度：[sigs,tfr,tfrv] = stfrftSeparationAdv(x,ifs,halfLen,h)
% 输入：x：输入信号，是多个分量的叠加
%           ifs：各列是各个分量的瞬时频率，
%                 **不同于STFT下的是，此处的ifs必须是连续变化的值，否则会导致求导为0，阶数判断错误，进而影响STFT下信号恢复的性能！！
%                 **【如果是TFR域估计的瞬时频率，建议先对频率进行保持边缘的低通滤波再执行本时变滤波操作】
%           halLen：固定窗长度的窗半长度
%           h：可选一行或者一列输入的窗函数，需要注意h(0)=1，否则无法恢复信号。
% 输出：sigs：输出信号，各列表示一个信号
%           tfr：三维矩阵分别表示各个分量的STFRFT谱
%           tfrv：三维矩阵分别表示各个分量的STFRFT谱
%           ucs：STDRFT谱中各个横轴对应的频率值

% 可调节的参数
thr = 0.2;%时变滤波的限定值【和噪声有关，且值越大信号的幅度衰减越大，需要将幅度根据这个值补回来】

assert(nargin>=2,'At least 2 parameter is required.');
% 时变滤波时重复边缘的宏控制，为了避免时变滤波边缘衰变设置该参数，可选设置为1或者0
EDGE_REPEAT = 1;%

%参数初始化
x = x(:);   tLen = length(x);  t=1:tLen; %获取时间长度
fLen = min([tLen, 512]);%频域最大分辨率为512
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

% 计算旋转阶数和对应FRFT域频率
ps = zeros(size(ifs)); ucs = zeros(size(ifs));
for is = 1:sigN
    [~,uc,p] = fftIflaw2frftIflaw(ifs(:,is),fLen);
    %这里最好修正一下频率值为nan的地方，要么设置其为0要么设置其为最近的非nan值
    ucs(:,is) = mod(round(uc),fLen)+1;%uc作为下标必须为整数
    ps(:,is) = p;
end


tfr= zeros(fLen,tLen,sigN) ;midN = round(fLen/2);% TFR参数初始化
sigs = zeros(tLen,sigN);tfrv = zeros(fLen,tLen,sigN) ;
for it=1:tLen,
    ti= t(it); tau=max([-midN+1,-Lh,-ti+1]):min([midN-1,Lh,tLen-ti]);
    if EDGE_REPEAT
        %taux = [tau(1)*ones(1,tau(end) - abs(tau(1))),tau,tau(end)*ones(1,abs(tau(1))-tau(end))];%重复边缘为边缘值
        taux = [zeros(1,tau(end) - abs(tau(1))), tau,zeros(1,abs(tau(1))-tau(end))];%重复边缘为当前值
        tauh = 1:hrow;%全部重复
        indices= (midN-Lh) : (midN + Lh);%值重复保存
    else
        taux = tau;
        tauh = Lh+1+tau;
        indices= rem(midN+tau-1,fLen)+1;
    end
    % 计算原始STFRFT
    stmp = zeros(tLen,1);
    stmp(indices)=x(ti+taux,1).*conj(h(tauh));
    %对各个信号时变滤波
    for is = 1:sigN
        %该时刻频谱的滤波
        tfr(:,it,is)=frft(stmp,ps(it,is));%计算FFT谱，对每个时刻
        ftfr = tvfIter(tfr(:,it,is), ucs(it,is), thr, halfLen);%频域滤波，频域的矩形窗。适当放宽限制。
        %信号时域值恢复
        st = ifrft(ftfr,ps(it,is));%滤波后的数据反变换
        sigs(it,is) = st(midN);%加入的数据是中间值，滤波恢复的也得是中间值
        %plot(t,real(stmp),'b.-',t,real(st),'r.-')%调试信号
        tfrv(:,it,is) = ftfr;
        % 修正旋转跳变
        if ps(it,is)<0
            tfr(1:fLen,it,is) = tfr(fLen:-1:1,it,is);%将其校正为正确的值范围
            tfrv(1:fLen,it,is) = tfrv(fLen:-1:1,it,is);
            ucs(it,is) = fLen - ucs(it,is);%返回校正后的真是STFRFT频率
        end
    end
end

end


function y = tvfIter(x, ind, thr, maxLen)
% 对输入的频域数据x，从ind处往两边延伸查找到峰值边界，之后将其它数据归0。
% 边界的定义：其幅值小于阈值edgeThr*max且是极小值的点。如果查找到的极值点超过maxLen则放弃。
edgeThr = 0.4; %边缘
Len = length(x);
y = zeros(size(x));%默认都是0
y(ind) = x(ind); maxAbs = abs(x(ind));%计算最大值
%% 往前搜索
absp = maxAbs;
for len = 0:maxLen %注意需要包含0长度点
    indc = mod(ind-len,Len) + 1; %往左边找
    absc = abs(x(indc));
    if maxAbs<absc; maxAbs = absc; end
    if (absc < maxAbs*thr); break; end %到达阈值
    if (absc < maxAbs * edgeThr) && (absc > absp); break;  end%边界到达条件
    y(indc) = x(indc);%本节点包含到滤波后的数据
    absp = absc; %记录本节点的幅值
end
%% 往后搜索
absp = maxAbs;
for len = 0:maxLen 
    indc = mod(ind+len,Len) + 1; %往右边找
    absc = abs(x(indc));
    if maxAbs<absc; maxAbs = absc; end
    if (absc < maxAbs*thr); break; end %到达阈值
    if (absc < maxAbs * edgeThr) && (absc > absp); break;  end%边界到达条件，主要是为了抑制交叉分量
    y(indc) = x(indc);%本节点包含到滤波后的数据
    absp = absc; %记录本节点的幅值
end

end

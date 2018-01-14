function s_hat = stftTvf_1Cmpnt(sn)
%% 针对单分量FM信号的FFT时变滤波，必须针对单分量才能调用本函数。
% 依赖：时频分析工具箱 TFSAP
% 注意：输入信号必须为连续FM（不能是跳频）。
% 输入：sn为实数信号，含噪声和干扰等。
% 输出：s_hat为重建的FM信号

fftLen = 128; % IF估计窗长度

% 信号初始化准备
s = hilbert(sn(:));%转换为解析信号
ifs = zce( s, fftLen);% 瞬时频率估计TFSAP %plot(ifs)
ifsFix = filterIfs(ifs);%平滑IF信息 % plot(ifsFix)
% t = 1:length(ifsFix);plot(t,ifs,'b',t,ifsFix,'k');legend('zce','fix');

% 信号重建
[s_hat,tfr,tfrv ]= stft_rec(s,ifs,8);%重建
% figure;subplot(121);imagesc(abs(tfr)); axis xy; 
% subplot(122);imagesc(abs(tfrv)); axis xy; 

s_hat = reshape(s_hat,size(sn,1),size(sn,2));%保持信号尺寸不变



end



function y=filterIfs(x,winLen)
% 对IF信息进行平滑
if(nargin<2 || isempty(winLen)) winLen=15; end
w=hamming( floor(winLen) ); w=w./sum(w);
abs_mean=mean(x);
y=conv(x-abs_mean,w,'same');
y=y+abs_mean;
% 将两端的IF信息采用边缘填充的方法，避免ZCE估计的IF信息边缘
y = [ones(winLen,1)*y(winLen+1);
    y(winLen+1 : end - winLen);
    ones(winLen,1)*y(end - winLen)];

end


function [sigs,tfr,tfrv] = stft_rec(x,ifs,halfLen,h)
%% 基于短时傅立叶变换时变滤波的信号分离，自适应窗长度：[sigs,tfr,tfrv] = stftSeparationAdv(x,ifs,halfLen,h)
% 输入：x：输入信号，是多个分量的叠加
%           ifs：各列是各个分量的瞬时频率，可以是归一化到-0.5到0.5的，也可以是1-N的数字频率。
%           halfLen：最大窗半长度，需要注意的是这里实际调用时【将其扩展4*thr+1倍以便更灵活适应】，但是具体扩展长度还有待优化。
%           h：可选一行或者一列输入的窗函数，需要注意h(0)=1，否则无法恢复信号。
% 输出：sigs：输出信号，各列表示一个信号
%           tfr：计算得到的STFT谱
%           tfrv：三维矩阵分别表示各个分量的STFT谱

% 可调节的参数
thr = 0.2;%时变滤波的限定值【和噪声有关，且值越大信号的幅度衰减越大，需要将幅度根据这个值补回来】

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
        tauh = 1:hrow;%全部重复
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
        ftfr = tvfIter(tfr(:,it), ifs(it,is), thr, halfLen);%频域滤波，频域的矩形窗。适当放宽限制。
        %信号时域值恢复
        st = ifft(ftfr);%滤波后的数据反变换
        sigs(it,is) = st(midN);%加入的数据是中间值，滤波恢复的也得是中间值
        %plot(t,real(stmp),'b.-',t,real(st),'r.-')%调试信号
        tfrv(:,it,is) = ftfr;
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




function [sigs,tfr,tfrv] = synsqCwtSeparationAdv(x,ifs,halfLen)
%% 基于压缩同步小波变换时变滤波的信号分离，固定窗长度：[sigs,tfr,tfrv] = synsqCwtSeparationAdv(x,ifs,halfLen)
% 输入：x：输入信号，是多个分量的叠加
%           ifs：各列是各个分量的瞬时频率
%           halLen：固定窗长度的窗半长度
% 输出：sigs：输出信号，各列表示一个信号
%           tfr：三维矩阵分别表示各个分量的STFRFT谱
%           tfrv：三维矩阵分别表示各个分量的STFRFT谱

assert(nargin>=2,'At least 2 parameter is required.');
thr = 0.1;%时变滤波的限定值【和噪声有关，且值越大信号的幅度衰减越大，需要将幅度根据这个值补回来】

%参数初始化
x = real(x(:));   tLen = length(x);  t=1:tLen; %获取时间长度
[~,sigN] = size(ifs);%获取信号的数量
fLen = min([tLen, 512]);%频域最大分辨率为512
vice = round(fLen/9);% synsq_cwt_fw 变换的近似分块
% fLen = vice*9;

%% 计算SCWT谱
[Tx, fs,~,~,~] = synsq_cwt_fw(t,x,vice);
fLen = size(Tx,1);% 这里才是真正的频率点
tfr = Tx; % 合成谱


%% 迭代分离
tfrv= zeros(fLen,tLen,sigN) ;
sigs = zeros(size(ifs));
for is = 1:sigN
    %% 查找Tx纵坐标中离ifs最近的一个点的坐标作为峰值寻找当前的极值
    Txfk = zeros(fLen,tLen);
    for it = 1:tLen
        [~,ifc] = min(abs(ifs(it,is) - fs));
        tmp = tvfIter(abs(Tx(:,it)),ifc,thr,halfLen);
        kep = find(tmp>0);
%         Txfk(kep,it) = Tx(kep,it);
        % 最好的方法还是用找到的index通过synsq_filter_pass获得上下边界
        try
            uif(it) = fs(kep(end));dif(it) = fs(kep(1));
        catch
            if it == 1
                uif(it) = fs(5);dif(it) = fs(1);% 第一个可能保留为0
            else
                uif(it) = uif(it-1);dif(it) = dif(it-1);% 发生异常时保留上一个时刻的值即可，
            end
        end
    end
    
    [Txfk,~,~] = synsq_filter_pass(Tx,fs,dif,uif);%假设IF估计精确
    skh = synsq_cwt_iw(Txfk,fs);
    %% 输出赋值
    sigs(:,is) = hilbert(skh(:));
    tfrv(:,:,is) = Txfk;
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

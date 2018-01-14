function [sigs,tfr,tfrv] = synsqCwtSeparation(x,ifs,halfLen)
%% 基于压缩同步小波变换时变滤波的信号分离，固定窗长度：[sigs,tfr,tfrv] = synsqCwtSeparation(x,ifs,halfLen)
% 输入：x：输入信号，是多个分量的叠加
%           ifs：各列是各个分量的瞬时频率
%           halLen：固定窗长度的窗半长度
% 输出：sigs：输出信号，各列表示一个信号
%           tfr：三维矩阵分别表示各个分量的STFRFT谱
%           tfrv：三维矩阵分别表示各个分量的STFRFT谱


assert(nargin>=2,'At least 2 parameter is required.');
epsIf = 1e-2; % 阈值

%参数初始化
x = real(x(:));   tLen = length(x);  t=1:tLen; %获取时间长度
[~,sigN] = size(ifs);%获取信号的数量
fLen = min([tLen, 512]);%频域最大分辨率为512
vice = round(fLen/9);% synsq_cwt_fw 变换的近似分块
fLen = vice*9;
ifs = ifs * 0.498*2 + 0.002; % fs是从0.02开始的，因此有必要这样开始

%% 计算SCWT谱
[Tx, fs,~,~,~] = synsq_cwt_fw(t,x,vice);
tfr = Tx; % 合成谱

df = halfLen/fLen;% 固定窗长度实际上乘2了

%% 迭代分离
tfrv= zeros(fLen,tLen,sigN) ;
sigs = zeros(size(ifs));
for is = 1:sigN
    uif = ifs(:,is) .* (1+df) + epsIf;
    dif = ifs(:,is) .* (1-df) - epsIf;
    [Txfk,~,~] = synsq_filter_pass(Tx,fs,dif,uif);%假设IF估计精确
    skh = synsq_cwt_iw(Txfk,fs);
    %% 输出赋值
    sigs(:,is) = hilbert(skh(:));
    tfrv(:,:,is) = Txfk;
end


end

% 
% function y = tvfIter(x, ind, maxLen)
% % 固定窗长度滤波器
% Len = length(x);
% y = zeros(size(x));%默认都是0
% y(ind) = x(ind);
% %% 往前搜索
% for len = 0:maxLen %注意需要包含0长度点
%     indc = mod(ind-len,Len) + 1; %往左边找
%     y(indc) = x(indc);%本节点包含到滤波后的数据
% end
% %% 往后搜索
% for len = 0:maxLen 
%     indc = mod(ind+len,Len) + 1; %往右边找
%     y(indc) = x(indc);%本节点包含到滤波后的数据
% end
% 
% end
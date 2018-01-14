function sigs_o = amplitudeSacle(sigs, tfr, tfrv)
%% sigs_o = amplitudeSacle(sigs, tfr, tfrv) 根据输入的各个分量信号sigs和相应滤波前后谱重建信号sigs_o
% 输入：
%       sigs： 结构体数组，表示多个分量的信号
%       tfr : 信号的完整时频分布
%       tfrv： 时变滤波输出的滤波后分布
% 输出：sigs_o和输入sigs一样的含义，但是修复了幅度叠加的地方
% 【对失真处不知道如何处理，功能未完善！不可用】

[~,sigN] = size(sigs);%长度确定
sigs_o = sigs;% 信号初始化
oTfr = sum(tfrv,3) - tfr.*(sum(abs(tfrv),3)~=0); %交叉处的位置

% 信号畸变的修正
for k = 1:sigN%对各个信号
    % 计算各个信号叠加部分的幅值
    [r,c] = find(oTfr~=0);%找到交叉分量不为0的地方
    oTfrk = zeros(size(tfr));    oTfrk(r,c) = tfrv(r,c,k);%取分量k存在于交叉分量地方的值
    sacleS = sum(oTfrk,1);%计算各个时刻的叠加幅度值
    N0Number = sum(oTfrk~=0,1) + 1;%找到非0点的数量
    sacle = sacleS./N0Number;
    inder = find(sacle~=0);%找到不为0的位置就是有叠加的位置
    sacle = 1 + filterAbs(sacle, 15);
    %subplot(211);imagesc(abs(oTfrk));axis xy;subplot(212);plot(abs(sacle));axis tight
    %hold on;plot(abs(sum(tfrv(:,:,1))),'r')
    sigs_o(inder,k) = sigs(inder,k)./sacle(inder).';%幅度调制
end



end

function abs_smooth=filterAbs(x,winLen)
%---------------------------------------------------------------------
% filter IF law by convolving with Hamming window
%---------------------------------------------------------------------
if(nargin<2 || isempty(winLen)) winLen=15; end

w=hamming( floor(winLen) ); w=w./sum(w);

abs_mean=mean(x);
abs_smooth=conv(x-abs_mean,w,'same');
abs_smooth=abs_smooth+abs_mean;

end

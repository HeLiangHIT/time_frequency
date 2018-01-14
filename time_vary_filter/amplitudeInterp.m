function sigs_o = amplitudeInterp(sigs, sifs, enLen, edgeLen)
%% sigs_o =amplitudeInterp(sigs, sifs, enLen, edgeLen) 根据输入的各个分量信号sigs和相应滤波前后谱重建信号sigs_o
% 输入：
%       sigs： 结构体数组，表示多个分量的信号
%       sifs : 信号各个分量的瞬时频率
%       enLen : IF交叉点扩展距离，在该距离内都进行插值
%       edgeLen：边缘幅度衰变的长度，通常建议为STFT时变滤波求TFR窗长度的1/4
% 输出：sigs_o和输入sigs一样的含义，但是修复了幅度叠加的地方

[tLen,sigN] = size(sigs);%长度确定
t = 1:tLen; %时刻点
sigs_o = zeros(size(sigs));% 信号初始化

enLarge = ones(enLen);%IF交点两边扩展长度
for k=1:sigN;    tfrv(:,:,k) = imdilate(tfrideal(sifs(:,k)),enLarge);    end
stfr = sum(tfrv,3);%和时频分布

% 信号畸变的修正
for k = 1:sigN%对各个信号
    %x = hilbert(sigs(:,k));%第k个分量的信号，希尔伯特变换获取信号瞬时幅度
    %其实信号本身就是一个复数信号，无需希尔伯特变换直接abs就是信号的幅度。因此直接拟合幅度就行了。
    x_abs = abs(sigs(:,k));%分量信号的幅度
    % 计算各个信号叠加部分的幅值
    oTfrk = tfrv(:,:,k).*stfr - tfrv(:,:,k);%取分量k存在于交叉分量地方的值
    overlays = sum(abs(oTfrk),1);%计算各个时刻的叠加幅度值
    %imagesc(abs(oTfrk));axis xy;figure;plot(overlays);axis tight
    cor_index = find(overlays==0);%找到交叉点之外的数据作为插值已知点
    if length(cor_index)< 3; sigs_o(:,k) = sigs(:,k); continue; end
    if length(cor_index) > 2* edgeLen;%满足超过长度的情况下才可以插值，否则只能取其中间两个值
        %cor_index = cor_index(edgeLen:end - edgeLen);%去除边缘部分的值，后面再插值即可
        x_abs(1:edgeLen) = x_abs(edgeLen);   x_abs(end - edgeLen:end) = x_abs(edgeLen);%边缘无法插值，只能直接取值
    end
    x_abs_hat = interp1(cor_index,x_abs(cor_index),t,'linear');%线性插值是最好的方式 linear ,
    x_abs_hat = filterAbs(x_abs_hat,20)'; %平滑处理% plot(t,x_abs_hat,'k.-')
    sigs_o(:,k) = sigs(:,k)./x_abs.*x_abs_hat;%幅度调制
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

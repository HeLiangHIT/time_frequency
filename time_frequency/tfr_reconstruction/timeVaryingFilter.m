function sigs = timeVaryingFilter(tfr,winLen,f)
% function sigs = timeVaryingFilter(tfr,winLen,f,type,param,param2)
%% 产生时频谱事变滤波器的函数
% 输入：tfr信号stft时频谱，Len窗长度，f各列表示该分量的瞬时频率分量（NAN表示该处无频率）
%           type 滤波器加窗类型
% 输出：sigs各列表示该列的信号

[tLen,fLen] = size(tfr);%长度确定
if max(f(:))<=0.5 %当输入频率分量是归一化的时执行的处理
    f = round(f*fLen);%瞬时频率->Y轴坐标位置
else%输入频率分量并非归一化的，而是从图像中得到的真实频率点
    f = round(f/2);%如果是使用WVD扩展谱图像得到的，则需要除以2，因为STFT存在扩延
end

assert(mod(winLen,2)==0,'输入窗长度必须为偶数以保证对称！');

% 时变滤波窗函数
Win = tftb_window(winLen,'Hamming');
baseWin = [Win; zeros(fLen-winLen,1)];%窗
baseWin  = circshift(baseWin,-winLen/2,1);%plot(baseWin); axis tight
% 时变滤波幅度修正
amf = ones(tLen,size(f,2));%默认都是放大1
mainWin = zeros(tLen,fLen);%测试用
for n = 1:size(f,2)%每个分量
    for k = 1:tLen%每个时刻
        if isnan(f(k,n))%频率值为nan
            win{n}(:,k) = zeros(fLen,1);%没有频率值则窗值全为0
        else
            win{n}(:,k) = circshift(baseWin,f(k,n),1);%窗循环平移到IF中心
            %这样操作智能针对解析信号的STFT谱有效，如果是实数信号应该需要修改为如下：
            %win{n}(:,k) = circshift(baseWin,f(k,n),1) + circshift(baseWin,-f(k,n),1);%窗循环平移到IF中心
            
            %计算时变滤波幅度修正量
            fadd = abs(f(k,:)-f(k,n)) + 1;%在该点存在重叠的分量
            fadd = fadd(~isnan(fadd)); %去掉nana的值
            scale = sum(baseWin(fadd)); %叠加的放大效果
            %amf(k,n) = 1.5-0.5*scale;%线性关系，适用于2分量信号
            %amf(k,n) = cos(2.0*pi*(scale-1)/6);%t=0:0.01:2;h=cos(2.0*pi*(t-1)/6);plot(t,h)%Hamming：h=0.54-0.46*cos(2.0*pi*(1:N)'/(N+1));
            %amf(k,n) = 1/scale;%线性关系，适用于多分量信号
            mainWin(:,k) = mainWin(:,k) + win{n}(:,k)*amf(k,n);%测试用
        end
    end
    %surf(win{n})
end


%% 绘制窗函数和，可以发现窗函数叠加处周围的放大情况，因此需要将其设法处理
% surf(mainWin);%两分量时正好放大2倍，3分量时正好放大3倍咯



for k = 1:length(win)
    tfrk = tfr.*win{k};%频域滤波%imagesc(abs(tfrk))
    % 需要修正频率重叠的区域的幅度
    sigs(:,k) = sum(tfrk,1)/fLen;%提取后的信号
end

sigs = sigs.*amf;%交叉处幅度校正！

end



function [tfr,fc]= stfrftShift(tfr,fc,uc)
%% tfr= stfrftShift(tfr,fc,uc)
% 校正STFRFT谱相对STFT的折叠偏移频率
% 输入：tfr是求得的实际FRFT谱频率。
% fc 是各个点的STFT瞬时频率值，uc是各点STFRFT的瞬时频率值。
% 输出：tfr是修正后的连续TFR谱，主要是便于人眼观察其FRFT谱。
% fc就是输出的uc，其实就是将uc变换到fc位置了

% 输入校正
[fLen,tLen] = size(tfr);
dis = round(mod(fc,fLen) - mod(uc,fLen));%整数偏移量

for k = 1:tLen
    tfr(:,k) = circshift(tfr(:,k),dis(k),1);%将其移动到STFT的IF位置
end

end
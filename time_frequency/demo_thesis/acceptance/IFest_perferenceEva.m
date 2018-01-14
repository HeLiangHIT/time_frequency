function hiferr = IFest_perferenceEva(hif_hat,sif_ideal,N)
%% 根据估计的多个hif_hat结构体来计算各个估计IF的性能
% hif_hat 是cell，各个元素包含各个IF估计算法的估计结果
% hif_ideal 是一个矩阵，各列表示各个信号的if估计值
% N 频率采样点数

%% 数据清洗
sif_ideal(sif_ideal<0) = sif_ideal(sif_ideal<0) + 0.5;%负频率的不允许产生
sif_ideal = sif_ideal * N*2;

%% 具体的IF估计算法性能评估
hiferr = zeros(size(sif_ideal,2),length(hif_hat));
for k1 = 1:size(sif_ideal,2)
    sif = sif_ideal(:,k1);
    for k2 = 1:length(hif_hat) % 遍历三个算法，对每个算法的估计结果计算最接近的值作为评估值
        hif = hif_hat{k2}; rmse = zeros(1,length(hif));%初始化数据
        for k3 = 1:length(hif)
            % 计算本hif(k3)到sig(k1)的 RMSE值
            sif_chip = sif_ideal(hif{k3}(:,1),k1);
            hif_chip = hif{k3}(:,2);
            %plot(sif_chip,'r.-'); hold on; plot(hif_chip,'ko-');
            rmse(k3) = sqrt(sum( (sif_chip - hif_chip).^2 ) /N );
        end
        % 计算本hif(k3)到sig(k1)的最近距离作为其对第k1个IF的估计值
        hiferr(k1,k2) = min(rmse);
    end
end

hiferr = hiferr/N;% 归一化为各个点的平均频率估计误差
hiferr = mean(hiferr,1);%对信号分量个数平均一下

end
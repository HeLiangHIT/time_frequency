function [hif1,hif2] = IFest_compare_algorithm(tfr,delta_freq_samples,min_track_length,max_peaks,lower_prctile_limit)
% 对比算法性能的图像，参数参考代码实现。

% 算法参数
if nargin < 2; delta_freq_samples= 10; end%IF追踪的梯度，设置最大为10个图像距离
if nargin < 3;min_track_length=20; end%最短跟踪IF片段长度

%% 算法实现
% 出生-死亡 频率 BDIF 估计算法：需要已知信号个数--先验知识
if nargin < 4;max_peaks = 3; end% 三个信号分量
hif1 = tracks_MCQmethod(tfr,1,delta_freq_samples,min_track_length,max_peaks);% (tf,Fs,delta_limit,min_length,MAX_NO_PEAKS)

% 图像峰值检测-连接 LPDCL 算法
if nargin < 5;lower_prctile_limit = 75; end % 忽略低于该能量的百分比
hif2 = tracks_LRmethod(tfr,1,delta_freq_samples,min_track_length,lower_prctile_limit);%(tf,Fs,delta_limit,min_length,LOWER_PRCTILE_LIMIT )


end
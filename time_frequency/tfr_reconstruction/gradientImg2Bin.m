function rBin = gradientImg2Bin(img,segs,portion)
% 提取获取的梯度均值率图像的脊线，获得二值图像。以便后期的IF估计二值图像处理。
% segs = 1000; %分段1000
% portion = 0.8;%丢掉0.8的值较小的数据--置0，保留最大的20%作为二值化1

riHist = hist(img(:),segs);%查找直方图分布
riPro = cumsum(riHist)/sum(riHist);%概率密度分布
ind = find(riPro>portion);
thr = max(img(:))*ind/segs;%阈值低于thr部分就被设置为0，高于thr的部分设置为1
rBin = img>thr(1);

end
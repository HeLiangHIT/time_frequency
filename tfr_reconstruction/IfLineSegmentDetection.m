function [lines,rBin,rImg] = IfLineSegmentDetection(img,portion,mthd)
%% 检测输入img图像（主要针对时频分布图像）中的所有曲线片段
% 输入 img 图像，double
% 输出lin结构体数组，检测到的各个曲线片段的连续IF数据，
% 后期需要将lin{k}中比较相邻的连接起来，将其中比较短小的干掉。曲线的两端分岔合并+延长两端
% 输出rBin是二值化后的均值梯度图像，包含带宽等信息。
% 参考：Zhang H, Bi G, Yang W, et al. IF estimation of FM signals based on time-frequency image[J]. IEEE Transactions on Aerospace and Electronic Systems, 2015, 51(1): 326-343.

% 脚本测试代码：
% clear all; clc; close all;
% load img %导入图像内容
% img = img(1:2:end, 1:2:end);%缩小图像加快处理速度
% figure; imagesc(img);axis xy

if nargin<3
    mthd = 'gradient';
end%normal其它情况


%% 参数初始化
winLen = ceil(length(img)/50);%窗长度为2*winLen+1，这个长度需要人工根据时频图的窗尺寸决定
% img = img(1:5:end, 1:5:end)时选择3；img = img(1:2:end, 1:3:end)时选择6；
% img=img不变时选择11。==>winLen = ceil(length(img)/50);
segs = 1000;%rImg细分数量
% portion = 0.94;%rImg置0数量
cleanArea = round(winLen*winLen/2);%删除面积小于此值的部分百块--因为这极有可能是噪声

if strcmp(mthd,'gradient')
    %% 计算梯度图像
    [beta0, beta1, beta2]= gradientVector(img,winLen);%公式6计算beta0、1、2
    [beta1fix, beta2fix] = vectorModify(beta1,beta2);% 梯度向量修正
    % [x,y] = meshgrid(1:size(img,2),1:size(img,1));%绘图专用坐标修正
    % figure; quiver(x(:),y(:),beta2(:),beta1(:));axis tight;%绘制Fig2左，这里的beta1和beta2与书上貌似有点反
    % figure; quiver(x(:),y(:),beta2fix(:),beta1fix(:));axis tight;%绘制Fig2左，这里的beta1和beta2与书上貌似有点反

    %% 计算均率图像Mean ratio images，并根据能量占比二值化
    % rImg = meanGradientRatioImg(beta0, beta1, beta2, beta1fix, beta2fix);
    rImg = meanGradientRatioImgEasy(beta0, beta1, beta2, beta1fix, beta2fix,winLen);
    % figure; surf(rImg); axis tight
else
    rImg = img;
end
rBin = gradientImg2Bin(img, segs, portion);

%% 细化后提取图像轮廓信息
rBinClean = bwareaopen(rBin,cleanArea,8);%imshow(rBinClean)
rBinfix = bwmorph(rBinClean,'thin',1000);%细化的次数和之前选择的窗长度有关
% figure;subplot(211);imshow(rBin);axis xy;
% subplot(212);imshow(rBinfix);axis xy;
% [L,num] = bwlabel(rBinfix, 8); S = regionprops(L, 'Area');lineSkel = bwmorph(rBin,'skel',Inf);
[lines, bimg]= bwboundaries(rBinfix',8);
% figure;
% for k=1:length(lines)
%     plot(lines{k}(:,1),lines{k}(:,2),'.-'); hold on; grid on;
%     axis([1,length(rBin),1, length(rBin)]);
% end

%% 建议：先把各个直线段拟合一下，因为如果参数设置不合理的话直线两端会有分岔。
% 目前针对img内容的图像效果，参数得出的结果还是不错。

end








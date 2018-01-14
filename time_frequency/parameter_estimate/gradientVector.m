function [beta0, beta1, beta2, vectij] = gradientVector(img,winLen)
% 根据公式6计算beta0/1/2，这里的beta1和beta2与论文上相反，主要是因为论文上beta1表示水平方向，beta2表示垂直方向
%结论： V = [beta2, beta1];

[maxI,maxJ] = size(img);%maxI表示垂直坐标最大值，maxJ表示水平坐标最大值
beta0 = zeros(size(img));beta1 = zeros(size(img));beta2 = zeros(size(img));
%计算邻域坐标
% [neibori, neiborj] = neighborIndex(img, winLen, 'mirror');%求解邻域坐标值，镜像填充
% % 【注：此处的领域可以直接在下面编写，不用两次循环去计算领域，比较节省循环时间】
method = 'mirror';
xi = [-winLen:winLen]';yi = xi';
Ax = sum(xi.^2);Ay = sum(yi.^2);
for k1 = 1:maxI
    for k2 = 1:maxJ
        %计算邻域
        h = (k1-winLen):(k1+winLen);%构造理想下标
        v = (k2-winLen):(k2+winLen);
        %下标修正-边缘调整
        if strcmpi(method, 'repeat')%大小写不敏感
            h(h<1) = 1; h(h>maxI) = maxI;%重复边缘像素
            v(v<1) = 1; v(v>maxJ) = maxJ;
        elseif strcmpi(method, 'mirror')%大小写不敏感
            h(h<1) = maxI + h(h<1); %小于1的部分采用maxI负向区域值
            h(h>maxI) = h(h>maxI) - maxI;%大于长度的部分采用正向1开始
            v(v<1) = maxJ + v(v<1);
            v(v>maxJ) = v(v>maxJ) - maxJ;
        else
            %默认是none不修正边缘错误
        end
        %cImg = img(neibori{k1,k2},neiborj{k1,k2});%子图像
        cImg = img(h,v);%子图像
        beta0(k1,k2) = sum(cImg(:))/(2*winLen+1).^2;%计算均值即可得到beta0
        beta1(k1,k2) = sum(xi.*sum(cImg,2))/Ax/winLen;%水平方向先累加，再乘水平下标差
        beta2(k1,k2) = sum(yi.*sum(cImg,1))/Ay/winLen;
    end
end

end

% 
% function [neibori, neiborj] = neighborIndex(img, winLen, method)
% % 计算邻域坐标矩阵，输入图像img和邻域半径winLen
% % method 为'repeat'时表示边界上重复像素点，还可以增加镜像等方法
% % 输出三维矩阵neibori/j，长宽等于图像img，各个像素点尺寸(2m+1)，分别表示原始图像ij处的邻域坐标
% % 测试：
% % img = [1:5;2:6;3:7]
% % [neibori, neiborj] = neighborIndex(img, 1, 'mirror');%求解邻域坐标值，镜像填充
% % cImg11 = img(neibori{1,1},neiborj{1,1})
% 
% % method = 'repeat';%重复边缘--适用于计算水平和垂直的加权系数
% % method = 'mirror';%镜像边缘--适用于给出原始信号的领域数值
% % method = 'none';%不修正边缘--适用情况还未确定
% 
% [maxI,maxJ] = size(img);%maxI表示垂直坐标最大值，maxJ表示水平坐标最大值
% neibori = cell(size(img));%保存垂直方向坐标index
% neiborj = cell(size(img));%保存水平方向坐标index
% 
% for k1 = 1:maxI%水平方向
%     for k2 = 1:maxJ%垂直方向
%         h = (k1-winLen):(k1+winLen);%构造理想下标
%         v = (k2-winLen):(k2+winLen);
%         %下标修正-边缘调整
%         if strcmpi(method, 'repeat')%大小写不敏感
%             h(h<1) = 1; h(h>maxI) = maxI;%重复边缘像素
%             v(v<1) = 1; v(v>maxJ) = maxJ;
%         elseif strcmpi(method, 'mirror')%大小写不敏感
%             h(h<1) = maxI + h(h<1); %小于1的部分采用maxI负向区域值
%             h(h>maxI) = h(h>maxI) - maxI;%大于长度的部分采用正向1开始
%             v(v<1) = maxJ + v(v<1);
%             v(v>maxJ) = v(v>maxJ) - maxJ;
%         else
%             %默认是none不修正边缘错误
%         end
%         neibori{k1,k2} = h;%水平方向的index
%         neiborj{k1,k2} = v;%垂直方向的index
%     end
% end
% 
% end
% 
% 


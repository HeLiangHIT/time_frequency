function rImg = meanGradientRatioImg(beta0,beta1, beta2, beta1fix, beta2fix)
% 根据公式9计算计算均率图像Mean ratio images
% 调用：rImg = meanGradientRatioImg(beta0, beta1, beta2, beta1fix, beta2fix);

[maxI,maxJ] = size(beta0);%maxI表示垂直坐标最大值，maxJ表示水平坐标最大值
method = 'mirror';
iniLen = 3;%【最好是根据TFD选择，和TFD曲线宽度近似比较好】
ep = 1e-2;%阈值，放置最大值太大
sigmoid = @(x) 4*iniLen*(1./(1+exp(-0.2*x)) - 0.5) + 1;%幅度--窗口长度：自适应函数

veci=zeros(size(beta0));
vecj=zeros(size(beta0));
rImg = zeros(size(beta0));

for k1 = 1:maxI
    for k2 = 1:maxJ
        %% 计算固定窗长度的邻域
        h = (k1-iniLen):(k1+iniLen);%构造理想下标
        v = (k2-iniLen):(k2+iniLen);
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
        %% 计算修正Vector图像均值获得旋转向量，然后产生自适应窗坐标矩阵（矩形包含的部分值为1）
        cImg1 = beta1fix(h,v);%子图像
        cImg2 = beta2fix(h,v);%子图像
        veci(k1,k2) = sum(cImg1(:))/(2*iniLen+1).^2;
        vecj(k1,k2)  = sum(cImg2(:))/(2*iniLen+1).^2;
        winLen = sigmoid(veci(k1,k2).^2 + vecj(k1,k2).^2);%窗自适应长度
        %[neibor,radius,squre] = neighborRectangleIndex(winLen, -vecj(k1,k2), -veci(k1,k2));%寻找邻域下标
        [neibor,radius,squre] = neighborRectangleIndex(winLen, vecj(k1,k2), veci(k1,k2));%寻找邻域下标
        
        %% 获取原图像中的子图，用于相乘
        h = (k1-radius):(k1+radius);%构造理想下标
        v = (k2-radius):(k2+radius);
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
        %% 绘图查看正确与否
        if veci(k1,k2).^2 +vecj(k1,k2).^2 > 50
            figure(1);clf;subplot(121)
            imagesc(beta0);axis xy; grid on;
            itmp = zeros(size(beta0));itmp(h, v) =neibor;
            subplot(122);imagesc(itmp); axis xy; grid on; hold on;
            [x,y] = meshgrid(1:length(beta0),1:length(beta0));%绘图专用坐标修正
            quiver(x(:),y(:),vecj(:),veci(:),'r');axis tight;%绘制窗方向图
        end
        
        %% 计算自适应窗内的的均值图像，公式9
        cImg1 = beta1fix(h,v).*neibor; cImg2 = beta2fix(h,v).*neibor;%子图像
        cImg3 = beta1(h,v).*neibor; cImg4 = beta2(h,v).*neibor;
        cImen1 = sum(cImg1(:))/squre;cImen2 = sum(cImg2(:))/squre;%子图像均值
        cImen3 = sum(cImg3(:))/squre;cImen4 = sum(cImg4(:))/squre;
        %rImg(k1,k2) = beta0(k1,k2) * (cImen1.^2 +cImen2.^2) /max([ep,cImen3.^2 +cImen4.^2]);
        rImg(k1,k2) = (cImen1.^2 +cImen2.^2) /max([ep,cImen3.^2 +cImen4.^2]);
        % 【这里应该有问题，测试一下cImen1是否和理想的一样远大于cImen3，毕竟坐标翻转了！！】

        %[veci(k1,k2),vecj(k1,k2)]
    end
end

%% 调试语句
% [x,y] = meshgrid(1:length(beta0),1:length(beta0));%绘图专用坐标修正
% figure; quiver(x(:),y(:),vecj(:),veci(:));axis tight;%绘制窗方向图
% figure; surf(sigmoid(veci.^2 + vecj.^2));axis tight;%绘制窗的数据大小
% figure; imshow(rImg>5); axis xy;axis tight;%绘制窗的数据大小


end


function [neibor,radius,squre] = neighborRectangleIndex(winLen, veci, vecj)
% 计算邻域矩形的坐标矩阵，其中winLen表示窗长度，矩形方向[veci, vecj]
% 返回一维向量作为下标即可，后面用于求beta1和beta2的均值以及rImg。


safeGuard = 0.5;%保险边缘
method = 'mirror';
if abs(veci)>abs(vecj)
    winHei = abs(winLen*vecj/veci);%取绝对值，保证窗长度>高度
else
    winHei = abs(winLen*veci/vecj);
end
% 长度对应向量方向，高度垂直向量方向
radius = round(sqrt(winHei.^2 + winLen.^2));%产生的方形半径
ind = -radius:radius;
[indi, indj] = meshgrid(ind,ind);%产生坐标

veci = veci/sqrt(veci.^2 + vecj.^2);
vecj = vecj/sqrt(veci.^2 + vecj.^2);
fun1 = @(x,y) (veci * x + vecj * y + winLen + safeGuard);%保险边缘
fun2 = @(x,y) (veci * x + vecj * y - winLen - safeGuard);
fun3 = @(x,y) (-veci * y + vecj * x + winHei + safeGuard);
fun4 = @(x,y) (-veci * y + vecj * x - winHei - safeGuard);
% ezplot(fun1); axis equal; grid on; hold on;
% ezplot(fun2); axis equal; grid on; hold on;
% ezplot(fun3); axis equal; grid on; hold on;
% ezplot(fun4); axis equal; grid on; hold on;
% axis([-radius,radius,-radius,radius]);plot([0,veci],[0,vecj],'r-')

neibor = fun1(indi,indj)>0 &  fun2(indi,indj)<0 & fun3(indi,indj)>0 & fun4(indi,indj)<0;
squre = sum(neibor(:)==1);%面积


end



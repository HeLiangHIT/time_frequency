function rImg = meanGradientRatioImgEasy(beta0,beta1, beta2, beta1fix, beta2fix, winLen)
% 根据公式9计算计算均率图像Mean ratio images
% 调用：rImg = meanGradientRatioImg(beta0, beta1, beta2, beta1fix, beta2fix);

[maxI,maxJ] = size(beta0);%maxI表示垂直坐标最大值，maxJ表示水平坐标最大值
method = 'mirror';
% winLen = 2;%【最好是根据TFD选择，和TFD曲线宽度近似比较好】
ep = 1;%这个值越大越可以抑制虚假峰值噪声，测试取0.5-1之间较好
rImg = zeros(size(beta0));

for k1 = 1:maxI
    for k2 = 1:maxJ
        %% 计算固定窗长度的邻域
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

        %% 计算自适应窗内的的均值图像，公式9
        cImg1 = beta1fix(h,v); cImg2 = beta2fix(h,v);%子图像
        cImg3 = beta1(h,v); cImg4 = beta2(h,v);
        cImen1 = sum(cImg1(:))/(winLen*2+1).^2;cImen2 = sum(cImg2(:))/(winLen*2+1).^2;%子图像均值
        cImen3 = sum(cImg3(:))/(winLen*2+1).^2;cImen4 = sum(cImg4(:))/(winLen*2+1).^2;
        rImg(k1,k2) = beta0(k1,k2) * (cImen1.^2 +cImen2.^2) /max([ep,cImen3.^2 +cImen4.^2]);
        %rImg(k1,k2) = (cImen1.^2 +cImen2.^2) /max([ep,cImen3.^2 +cImen4.^2]);

    end
end

rImg(rImg<0)=0; %surf(log10(rImg+1));axis tight
rImg = log10(rImg+1);%指数缩放后比较符合人眼直观感觉

end


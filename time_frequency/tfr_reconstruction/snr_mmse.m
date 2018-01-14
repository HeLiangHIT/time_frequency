%% 统计采用各种方法的MMSE和SNR
clear all; close all;clc

%% 原始信号产生和固定参数设置
[s_gen,s_itfr,s_org,iflaw] = signalGenLxLS();%指定2LFM+1SFM信号，无相交
iflaw(isnan(iflaw)) = 0;iflaw = iflaw*length(s_gen)*2;energy = std(iflaw,0,1).^2;
Gt = kaiser(15,1);%beta越大能力越集中
Hf = kaiser(61,1);%这两个长度参数结合相对默认的SPWVD参数较好
SNR = 5:2:35;
Niter = 20;%测试次数

nmse = zeros(length(SNR),length(s_org));

for iter = 1:Niter
    fprintf('iter = %d, totalIter = %d; \n',iter,Niter);
    for snr = 1:length(SNR)

        %% 添加噪声
        s = awgn(s_gen,SNR(snr),'measured');
        [tfr,rtfr] = tfrrspwv(s,1:length(s),length(s),Gt,Hf);%优于默认的汉宁窗效果

        %% 曲线提取
        img = tfr;%图像模拟
        portion = 0.95;%signalGenLLS和SS时选择0.9，signalGenLxLS时选择0.95
        [lines,rBin,rImg] = IfLineSegmentDetection(img,portion,'normal');%获取图像中的曲线信息%normal,gradient
        linesSim = linesSimplify(lines);%曲线去重

        %% 曲线拼接和修复
        linesInfo = curveModify(linesSim,length(s),0);%修复曲线分岔问题和垂直方向上存在多个点的问题
        linesCon = linesConnect(linesInfo,40);%曲线拼接 % k=1;plot(linesCon{k}(:,1),linesCon{k}(:,2),'rx-');hold on; grid on
        linesFinal = curveModify(linesCon,length(s),15);%再次修复曲线分岔问题和垂直方向上存在多个点的问题

        %% 分离原始信号--采用时变滤波方法对每一路信号时变滤波
        siflaw = [];
        for k = 1:length(linesFinal)
            ifk = nan(length(s),1);%瞬时频率默认为NaN，为了方便timeVaryingFilter的有无频率判别
            ifk(linesFinal{k}.line(:,1)) = linesFinal{k}.line(:,2);
            siflaw(:,k) = ifk*size(tfr,2)/size(tfr,1);%瞬时频率合成，归一化到WVD的频率系数上面，方便后面的时变滤波调用
        end
    %     tfr_stft = tfrstft_my(s);%surf(abs(tfr_stft))
    %     s_hat = timeVaryingFilter(tfr_stft,80,siflaw);%窗口长度设为60,需和STFT的宽度相同

        %% 误差统计
        siflaw(isnan(siflaw)) = 0;
        for k = 1:length(linesFinal)
            sifrep = repmat(siflaw(:,k),1,length(s_org));
            difrc = sum((sifrep - iflaw).^2,1);
            [mse,ind] = min(difrc);
            nmse(snr,ind) = nmse(snr,ind) + mse/energy(ind);%第几个分量的IF估计误差
        end
    end
end
nmse = nmse/Niter;%求均值
nmse = nmse/(max(nmse(:)));%归一化

subplot(4,1,1:3)
plot(SNR,10*log(nmse(:,1)),'b.-',...
    SNR,10*log(nmse(:,2)),'rx-',...
    SNR,10*log(nmse(:,3)),'ksquare-');
legend('分量1','分量2','分量3')

subplot(4,1,4)
plot(SNR,mean(nmse,2),'k.-');title('多分量估计总误差')










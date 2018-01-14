%% 复杂信号的分析
clear all; close all;clc

%% 1、选择信号的频率分析方式
[s_gen,s_itfr,s_org] = signalGenLLS();%指定2LFM+1SFM信号，无相交
% [s_gen,s_itfr,s_org] = signalGenLxLS();%指定2LFM+1SFM信号，有LFM和LFM相交
s = awgn(s_gen,500,'measured');
% [s,s_itfr,s_org] = signalGenSS();%指定2SFM信号
% plot(real(s_org{1}),'.-');axis tight
% figure;contour(s_itfr);% colormap('hot');
% title('理想时频分布');xlabel('f/Hz'),ylabel('t/s')%理想时频分布的查看

%% 2、BD时频分布对比--放弃该方法
% tfr = quadtfd( s, 127 , 1, 'emb',0.08,0.4);%计算BD谱
% figure; imagesc(tfr); colormap('hot');%p = tfsapl( s, tfr);
% xlabel('f/Hz'),ylabel('t/s');title('Extended Modified B-distribution');%理想时频分布的查看

%% 3、SPWVD分布
Gt = kaiser(15,1);%beta越大能力越集中
Hf = kaiser(61,1);%这两个长度参数结合相对默认的SPWVD参数较好
[tfr,rtfr] = tfrrspwv(s,1:length(s),length(s),Gt,Hf);%优于默认的汉宁窗效果
% figure; imagesc(tfr);colormap('hot');%发现rtfr有所偏差
% xlabel('f/Hz'),ylabel('t/s');title('SPWVD');%SPWVD

%% 4、图像处理--曲线提取
img = tfr;%图像模拟
portion = 0.9;%signalGenLLS和SS时选择0.9，signalGenLxLS时选择0.95
[lines,rBin,rImg] = IfLineSegmentDetection(img,portion,'gradient');%获取图像中的曲线信息
% figure;imshow(rBin); axis xy;
% figure
% for k=1:length(lines)
%     plot(lines{k}(:,1),lines{k}(:,2),'b.-'); hold on; grid on;
%     axis([1,length(rBin),1, length(rBin)]);
% end
linesSim = linesSimplify(lines);%曲线去重

%% 5、曲线拼接和修复
linesInfo = curveModify(linesSim,length(s),-1);%修复曲线分岔问题和垂直方向上存在多个点的问题
% figure;label={'ko-','bsquare-','rdiamond-','kv-','b^-','r<-','k<-','bpentagram-','rhexagram-','k+-','b*-','r.-','kx-'};
% for k = 1:length(linesInfo)
%     plot(linesInfo{k}.line(:,1),linesInfo{k}.line(:,2),label{1+mod(k,length(label))});hold on; grid on
%     linesInfo{k}.type
% end
linesCon = linesConnect(linesInfo,40);%曲线拼接%k=1;plot(linesCon{k}(:,1),linesCon{k}(:,2),'rx');hold on; grid on
linesFinal = curveModify(linesCon,length(s),15);%再次修复曲线分岔问题和垂直方向上存在多个点的问题
% figure;label={'ko-','bsquare-','rdiamond-','kv-','b^-','r<-','k<-','bpentagram-','rhexagram-','k+-','b*-','r.-','kx-'};
% for k = 1:length(linesFinal)
%     plot(linesFinal{k}.line(:,1),linesFinal{k}.line(:,2),label{k});hold on; grid on
%     linesFinal{k}.type
% end


%% 产生原始信号--采用时变滤波方法对每一路信号时变滤波
% 这样产生是不可以的，因为频率估计存在误差，导致错误累加无法恢复，时域波形相差越来越远
% for k = 1:length(linesInfo)
%     ifk = linesInfo{k}.line(:,2);
%     s_hat{k} = fmodany(ifk/length(s)/2,1);%产生调频信号
%     figure, plot(real(s_hat{k}),'b'), hold on; plot(real(s_org{k}),'r')
% end
% 时变滤波的IF组合+时变滤波
tfr_stft = tfrstft_my(s);%surf(abs(tfr_stft))
series = [1,3,2];% 肉眼发现：还原的2和3两个信号反了，因此交换一下
for k = 1:length(linesFinal)
    ifk = nan(size(tfr_stft,2),1);%瞬时频率默认为NaN，为了方便timeVaryingFilter的有无频率判别
    ifk(linesFinal{k}.line(:,1)) = linesFinal{k}.line(:,2);
    sif(:,series(k)) = ifk*size(tfr,2)/size(tfr,1);%瞬时频率合成，归一化到WVD的频率系数上面，方便后面的时变滤波调用
end
s_hat = timeVaryingFilter(tfr_stft,80,sif);%窗口长度设为60,需和STFT的宽度相同
st_hat = 0;
figure(1); label={'ko-','bsquare-','rdiamond-','kv-','b^-','r<-','k<-','bpentagram-','rhexagram-','k+-','b*-','r.-','kx-'};
for k = 1:length(s_org)
    subplot(length(s_org),1,k);
    plot(real(s_org{k}),label{11}); hold on;
    plot(real(s_hat(:,k)),label{12}); axis tight;
    legend('原始信号','恢复信号');
    st_hat = st_hat + s_hat(:,k);
end

%恢复前后总信号对比
figure; 
subplot(211),plot(real(s),'r.-'); hold on; plot(real(st_hat),'o-'); axis tight;title('加和信号');
subplot(212),plot(imag(s),'r.-'); hold on;  plot(imag(st_hat),'o-'); axis tight;legend('原始信号','恢复信号');















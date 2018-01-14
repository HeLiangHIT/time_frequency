function hif = IFest_proposed(tfr,delta_freq_samples,min_track_length,max_peaks,lower_prctile_limit,win1,win2)
% 在之前的算法估计出来的IF信息 hif_pre 的基础上估计增强图像后的hif

if nargin < 7
    win1 = 2; win2 = 5;%参数初始化
end

Fs = 100;N=length(tfr); %单位对应MHz, us
F_scale = Fs/N/2;

[beta0, beta1, beta2]= gradientVector(tfr,win1);%公式6计算beta0、1、2
[beta1fix, beta2fix] = vectorModify(beta1,beta2);% 梯度向量修正
% [x,y] = meshgrid(1:size(tfr,2),1:size(tfr,1));%绘图专用坐标修正
% figure('Name','原始梯度矩阵'); quiver(x(:),y(:),beta2(:),beta1(:));
% set_gca_style([8,8]);axis equal;axis off;
% figure('Name','旋转梯度矩阵'); quiver(x(:),y(:),beta2fix(:),beta1fix(:));
% set_gca_style([8,8]);axis equal;axis off;


% rImg1 = meanGradientRatioImgEasy(beta0, beta1, beta2, beta1fix, beta2fix,win1);
% figure('Name','固定窗增强'); imagesc(rImg1); set_gca_style([6,6],'img');
rImg2 = meanGradientRatioImg(beta0, beta1, beta2, beta1fix, beta2fix, win2);
% figure('Name','自适应窗增强'); imagesc(rImg2); set_gca_style([5,5],'img');
% rBin = gradientImg2Bin(rImg2, 1000, 0.98);%imshow(rBin)
% rImg2Fix = rImg2.*rBin;imagesc(rImg2Fix);set_gca_style([6,6],'img');
img = rImg2';%选择图像  imagesc(img)


[hif_pre,~] = IFest_compare_algorithm(img,delta_freq_samples,min_track_length,max_peaks,lower_prctile_limit);%只选择BDIF算法的输出作为估计
%% 图像连接算法
% IF片段拟合
label={'ro-','b.-','r^-','kv-','b^-','r<-','k<-','bpentagram-','rhexagram-','k+-','b*-','r.-','kx-'};%绘图参数
linesInfo = curveModify(hif_pre,N,-2);%修复曲线分岔问题和垂直方向上存在多个点的问题
% figure('Name','IFs FIT');
% for n=1:length(hif_pre) ;   hmcq=plot(hif_pre{n}(:,1)/Fs,hif_pre{n}(:,2)*F_scale,'ro-'); hold on;  end   %绘制IF曲线
% for k = 1:length(linesInfo);    hfit = plot(linesInfo{k}.line(:,1)/Fs,linesInfo{k}.line(:,2)*F_scale,'b.-');hold on;  end
% legend([hmcq,hfit],{'IF片段','拟合IF片段'}); set_gca_style([6,6]);grid off; ylim([0,50]);%方便放置图例
% xlabel('时间/\mus');ylabel('频率/Mhz');

% IF片段连接
linesCon = linesConnect(linesInfo,40);%曲线拼接
% figure('Name','IFs Connect');
% for k=1:length(linesCon);plot(linesCon{k}(:,1)/Fs,linesCon{k}(:,2)*F_scale,label{k});hold on; end
% set_gca_style([6,6]);grid off; ylim([0,50]);xlabel('时间/\mus');ylabel('频率/Mhz');

% 分量拟合
enLen = 20;
linesFinal = curveModify(linesCon,N,enLen);%--不要延伸太长以避免错误的IF也充满全屏
% figure('Name','IF FIT-pro');
% for k = 1:length(linesFinal);    
%     if length(linesFinal{k}.line)<(enLen*2 + 50); continue;end %% 去掉太短的IF分量信号
%     plot(linesFinal{k}.line(1:5:end,1)/Fs,linesFinal{k}.line(1:5:end,2)*F_scale, label{k});hold on; 
% end
% set_gca_style([6,6]);grid off; ylim([0,50]);xlabel('时间/\mus');ylabel('频率/Mhz');
% plot(t,sif1*Fs,'b^',t,sif2*Fs,'rv');

hif = linesFinal;



end
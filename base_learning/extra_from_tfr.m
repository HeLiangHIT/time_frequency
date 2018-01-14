%% 从时频分布中提取信息的方法



%% 1、相位偏移产生的干扰时移，查看干扰分量中蕴含的信号信息
clear all; close all; clc;
% 观察信号相位偏移产生的干扰时移：两个固定频率的信号叠加，其中一个相位改变
M=movpwdph(128); movie(M,10);%随着相位的移动干扰项也在移动，非常好看
% 观察信号相位偏移产生的干扰时移：固定频率信号，中间相位跳变
M=movpwjph(128,8,'C'); movie(M,10);%随着跳变相位的变化，信号TFR也在变化，在跳变点产生图案
% 这些特征可以用来检测相位跳变信号

%% 2、renyi信息计算
clear all; close all; clc;
sig=atoms(128,[64,0.25,20,1]);
[TFR,T,F]=tfrwv(sig);
R1=renyi(TFR,T,F)%-0.2075
sig=atoms(128,[32,0.25,20,1;96,0.25,20,1]);
[TFR,T,F]=tfrwv(sig);
R2=renyi(TFR,T,F)%0.779
sig=atoms(128,[32,0.15,20,1;96,0.15,20,1;32,0.35,20,1;96,0.35,20,1]);
[TFR,T,F]=tfrwv(sig);
R3=renyi(TFR,T,F)%1.8029
% R2-R1约等于1（四个原子），R3-R1约等于2（2个原子）>>>>如果将只有一个原子的信号作为信息量为0
% 那么可以利用renyi信息估计TFR分布中的距离较远信息单元个数。

%% 3、TFR域对LFM信号的检测例子
% ---只有一个信号在 AWGN中的测试
clear all; close all; clc;
N=64; 
sig=sigmerge(fmlin(N,0,0.3),noisecg(N),1);%信噪比指定
tfr=tfrwv(sig); 
contour(tfr,5);%绘制tfr域的图像以查看效果
htl(tfr,N,N,1);%图像中的霍夫变换直线检测
% 可以看到在参数（p,theta）中的峰值，可以指定阈值判断是否存在，并然后根据(rho,theta)-->(v0,theta)求得所需参数估计。
% 其实就是极坐标系转换为卡迪尔坐标系的变换即可。
% ---两个LFM信号的测试，由于WVD干扰项的震荡特性其在霍夫变换后影响被消弱。
sig=sigmerge(fmlin(N,0,0.4),fmlin(N,0.3,0.5),1);
tfr=tfrwv(sig); 
contour(tfr,5);
htl(tfr,N,N,1);%可以看出两个LFM信号


%% 4、时间-尺度域（量图-小波变换）提供的局部规则性检测
clear all; close all; clc;
sig=anasing(64);%Lipschitz singularity，H=0
[tfr,t,f]=tfrscalo(sig,1:64,4,0.01,0.5,256,1);%基于Morlet wavelet的scalogram
H=holder(tfr,f,1,256,32) %计算时间局部奇异点，-0.0381
sig=anasing(64,32,-0.5);%Lipschitz singularity，H=-0.5
[tfr,t,f]=tfrscalo(sig,1:64,4,0.01,0.5,256,1);
H=holder(tfr,f,1,256,32)%H=-0.5107






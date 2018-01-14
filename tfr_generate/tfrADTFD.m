function tfr= tfrADTFD(s,alpha1,alpha2,winLen)
%% 计算 adaptive directional filtering distribution：tfr = tfrADTFD(s,alpha1,alpha2,winLen)
% 参考：Boashash B, Khan N A, Ben-Jabeur T. Time–frequency features for
% pattern recognition using high-resolution TFDs: A tutorial review [J].
% Digital Signal Processing, 2015, 40(2015): 1-30.  第4.2节
% 参数：x ：输入实数或者复数矩阵，一维。
% alpha1/2： alpha1是DGF核的a参数，alpha2是DGF的b参数。
%                   分别控制DGF在t和f轴的扩展，通常设置a小(=2)、b大(=12)得到方向性很强的基本核。
% winLen： DGF核的大小，即滑窗大小。
% tfr：是输出的时频分布结果，正实数矩阵。

s = s(:);%维度匹配

%% 计算信号的WVD
times=1; % 频率采样点相对时域采样点的扩展倍数
tfrWvd = quadtfd(s, length(s)-1, 1, 'wvd',length(s)*times);%最后一个参数表示FFT长度


%% WVD滤波--得到改进后的TFR
alpha=0.6; %默认EMBD参数
if length(s)>200;     alpha=0.25;   end
% 选择EMBD核，参考[1] Barkat B, Boashash B. A high-resolution quadratic
% time-frequency distribution for multicomponent signals analysis [J]. IEEE
% Transactions on Signal Processing, 2001, 49(10): 2232-9. 
t=-floor(winLen/2):floor(winLen/2);%核的计算时间
h1=1./((cosh(t).^2).^alpha); h1=h1/sum(h1);
h2=1./((cosh(t).^2).^alpha); h2=h2/sum(h2);
embKer=h1'*h2;%EMBD是可分离核，因此可以直接两个核相乘即可。
tfrEmbd=filter2(embKer,tfrWvd);%得到EMBD谱


%% 计算各个方向的DGF核矩阵
endAngle=180; %总的旋转角度
stepAndle=3;%旋转核的旋转角度步长
% 计算旋转核 rotKer
[x,y]=meshgrid(-1:2/winLen:1,-1:2/winLen:1);
rotKer = cell(endAngle/stepAndle);
for k=0:endAngle/stepAndle-1
    angle=pi*k*stepAndle/endAngle;
    
    xr=x*cos(angle)-y*sin(angle);%公式52
    yr=x*sin(angle)+y*cos(angle);
    
    ker=exp((-1/2)*(((alpha1*xr).^2)+(alpha2*yr).^2));
    ker=ker.*(1-alpha2*alpha2*yr.^2);
    ker=ker/sum(sum(abs(ker)));
    rotKer{k+1} = ker;
end


%% 使用快速卷积的方法实现公式53--55中的卷积运算
[fLen,tLen]=size(tfrEmbd);
safeSize = paddedsize(size(tfrEmbd));%计算FFT2的保险长度
Ftfr = fft2(double(tfrEmbd), safeSize(1), safeSize(2));%频域实现，因此首先计算频域%imagesc(log10(1+abs(fftshift(Ftfr))))
FtfrAbs = fft2(double((abs(tfrEmbd))), safeSize(1), safeSize(2));%计算abs后的时频分布频域
% subplot(121);imagesc(log(1+abs(fftshift(Ftfr))));subplot(122);imagesc(log(1+abs(fftshift(FtfrAbs))));
absResult=zeros([safeSize(1)-length(ker) safeSize(2)-length(ker) endAngle/stepAndle]);%保存所有FtfrAbs的点与所有核的卷积结果的矩阵，用于选择角度
cmplxResult=absResult;%保存所有Ftfr的点与所有核的卷积结果的矩阵，用于保存结果
for k=0:endAngle/stepAndle-1
    kerk = rotKer{k+1};
    Fkerk = fft2(double(kerk), safeSize(1), safeSize(2));%DGF的频域，采用频域乘积实现。这一步骤可以在前面预计算完成的。
    
    Fmutiple = Fkerk.*Ftfr;%频域乘积实现卷积
    tfr_kerk = real(ifft2(Fmutiple));%切换回到时域
    cmplxResult(:,:,k+1)=(tfr_kerk(round(length(kerk)/2):end-round(length(kerk)/2), round(length(kerk)/2):end-round(length(kerk)/2)));
    Fmutiple = Fkerk.*FtfrAbs;
    tfr_kerk =( abs(ifft2(Fmutiple))).^2;%这里只保留ABS值作为输出
    absResult(:,:,k+1)=(tfr_kerk(round(length(kerk)/2):end-round(length(kerk)/2), round(length(kerk)/2):end-round(length(kerk)/2)));
end
% 寻找卷积值最大的角度下的计算结果
[~,a]=max(absResult,[],3);%公式55，查找最大值旋转角度所在旋转角度的坐标

%% 结果保存
tfr_opt=zeros(size(tfrEmbd));
for m=1:fLen %对于每一个时频点，选择最佳旋转角度下的值
    for n=1:tLen
        tfr_opt(m,n)=cmplxResult(m,n,a(m,n));%选择最大旋转角度的坐标得到的方向的源tfr值卷积结果
    end
end

%% 再次使用EMBD滤波，这会让分辨率降低
tfr=filter2(embKer,tfr_opt);
tfr(tfr<0)=0;




end


function PQ = paddedsize(AB, CD, PARAM)
%PADDEDSIZE Computes padded sizes useful for FFT-based filtering.
% PQ = PADDEDSIZE(AB), where AB is a two-element size vector,
% computes the two-element size vector PQ = 2*AB.
%
% PQ = PADDEDSIZE(AB, 'PWR2') computes the vector PQ such that
% PQ(1) = PQ(2) = 2^nextpow2(2*m), where m is MAX(AB).
%
% PQ = PADDEDSIZE(AB, CD), where AB and CD are two-element size
% vectors, computes the two-element size vector PQ. The elements
% of PQ are the smallest even integers greater than or equal to
% AB + CD -1.
%
% PQ = PADDEDSIZE(AB, CD, 'PWR2') computes the vector PQ such that
% PQ(1) = PQ(2) = 2^nextpow2(2*m), where m is MAX([AB CD]).
%
%   Copyright 2002-2004 R. C. Gonzalez, R. E. Woods, & S. L. Eddins
%   Digital Image Processing Using MATLAB, Prentice-Hall, 2004
%   $Revision: 1.5 $  $Date: 2003/08/25 14:28:22 $
if nargin == 1
    PQ = 2*AB;
elseif nargin == 2 && ~ischar(CD)
    PQ = AB + CD - 1;
    PQ = 2 * ceil(PQ / 2);
elseif nargin == 2
    m = max(AB); % Maximum dimension.
    % Find power-of-2 at least twice m.
    P = 2^nextpow2(2*m);
    PQ = [P, P];
elseif nargin == 3
    m = max([AB CD]); %Maximum dimension.
    P = 2^nextpow2(2*m);
    PQ = [P, P];
else
    error('Wrong number of inputs.')
end
end


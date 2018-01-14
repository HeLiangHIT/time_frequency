function [tfr,ang] = tfrCoStfrft(x,prec,N,h)
%% 局部优化的短时分数阶傅立叶变换计算：[tfr,ang] = tfrCoStfrft(x,prec,N,h)
% 输入：
%           x: 输入的时域数据，一行或者一列
%           prec: FRFT旋转角度精度
%           N：输出的频域长度，需要>=0
%           h：可选一行或者一列输入的窗函数，需要注意h(0)=1，否则无法恢复信号。
% 输出：
%           tfr：计算得到的STFRFT谱
%           ang：STFRFT在各个时刻的旋转角度，用于将tfr上估计的瞬时频率uc转换为fc
% 【写不下去了、、、、程序还未完成，不能使用】


x = fmlin(128,-0.1,-0.45) + fmlin(128,0.0,0.45);%测试信号
sigN = 2;%信号数量，需要设置为输入，需要先要知识判断信号数量。

EDGE_REPEAT = 1;

x = x(:);   tLen = length(x);  t=1:tLen;%参数初始化
% if (nargin < 1),    error('At least 1 parameter is required.');  end
if (nargin < 2),    prec = 0.1;     end;
if (nargin < 3),    N=tLen;     end;
if (nargin < 4),
    if (N<0),    error('N must be greater than zero.');end;
    hlength=floor(N/4);
    hlength=hlength+1-rem(hlength,2);
    h = tftb_window(hlength);
end
h = h(:);
hrow=length(h); Lh=(hrow-1)/2;
if (rem(hrow,2)==0),  error('H must be a smoothing window with odd length.');end
% h=h/norm(h);%保证h(0)=1，才能恢复信号
pSel = 0.5:prec:1.5;%产生旋转角度待选择的向量

tfr= zeros (N,tLen) ;midN = round(N/2);
angT = zeros(sigN,tLen);ang = zeros(sigN,tLen);
% 计算各个时刻的最佳旋转阶数：这时还无需加窗，否则会带来干扰
for it=1:tLen,
    ti= t(it); startT = ti - hlength +1; endT = ti + hlength -1;
    if startT<1; startT = 1;end
    if endT>tLen;endT = tLen;end
    taux = startT : endT;
    xtmp = x(taux,1);% 为了加速可以在这里只传递窗长度的数据到寻找阶数上面
    angT(:,it) = findOptimalFrfts(xtmp,pSel,sigN);%plot(real(xtmp))
end
% 对ang进行滤波平滑操作
for k = 1:sigN
    ang(k,:)=filterDataSafe(angT(k,:));%滤波后比较平滑不易出现TFR波动较大的情况
end
% ang = filterDataSafe(angT);%滤波后比较平滑不易出现TFR波动较大的情况
% plot(t,angT,'.-',t,ang,'r.-');

% 对各个时刻进行FRFT变换
for it=1:tLen,
    ti= t(it); tau=max([-midN+1,-Lh,-ti+1]):min([midN-1,Lh,tLen-ti]);
    if EDGE_REPEAT
        %taux = [tau(1)*ones(1,tau(end) - abs(tau(1))),tau,tau(end)*ones(1,abs(tau(1))-tau(end))];%重复边缘为边缘值
        taux = [zeros(1,tau(end) - abs(tau(1))), tau,zeros(1,abs(tau(1))-tau(end))];%重复边缘为当前值
        tauh = 1:hrow;%全部重复
        indices= (midN-Lh) : (midN + Lh);%值重复保存
    else
        taux = tau;
        tauh = Lh+1+tau;
        indices= rem(midN+tau-1,fLen)+1;
    end
    % 计算原始STFT
    xtmp = zeros(N,1);
    xtmp(indices) = x(ti+taux,1).*conj(h(tauh));
    for k = 1:sigN
        tfr(:,it)=tfr(:,it) + frft(xtmp,ang(k,it));%计算FRFT
    end
end


if (nargout==0),
    tfrqview(abs(tfr).^2,x,t,'tfrstft',h);
end
end


function [pOpts] = findOptimalFrfts(x,pSel,sigN)
% 查找所有极值点作为当前点的旋转角度

% 参数
thr = 0.05;%极值边缘条件的判决
winLen = 4;%半个窗口长度


pOpts = ones(sigN,1);
edgeLen = ceil(length(x)/4);%保留边缘易错点
xres = [x(1)*ones(edgeLen,1);x(:);x(end)*ones(edgeLen,1)];
% figure(1);subplot(sigN+1,1,1);t = 1:length(xres); plot(t,real(xres),'.-');hold on;
for k = 1:sigN
    % 计算
    [frt,pOpt,uOpt,~] = findOptimalFrft(xres,pSel);%获取最强分量的分布值
    frtm = signalFilterIter(frt, uOpt, thr, winLen);%去除最强分量
    pOpts(k) = pOpt;%保存多个值
    xk = ifrft(frtm,pOpt);
    xtmp = xres - xk;%计算残差
    xres = [xtmp(edgeLen + 1)*ones(edgeLen,1);xtmp(edgeLen + 1:end - edgeLen);xtmp(end - edgeLen)*ones(edgeLen,1)];%每次都去除边缘值
    
    %调试语句
%     figure(1);subplot(sigN+1,1,k);plot(t,xk,'rx-');
%     figure(1);subplot(sigN+1,1,k+1);t = 1:length(xres); plot(t,real(xres),'.-');hold on
%     figure(2); plot(t,abs(frt),'b.-',t,abs(frtm),'rx-')
end

end




function [frt,pOpt,uOpt,maxAm] = findOptimalFrft(x,pSel)
% 查找pSel中对x信号的最佳旋转阶数的FRFT变换
% 返回最佳旋转角度下的FRFT变换 frt、最佳旋转角度 pOpt、最大值所在的位置 uOpt， 最大幅值 maxAm

G=zeros(length(pSel),length(x));	%不同阶数的变换结果保存
maxAm=0;        %记录最大频点
for k=1:length(pSel)
    tmp=frft(x,pSel(k));      %分数阶傅立叶变换
    tmp_abs = abs(tmp);
    G(k,:)=tmp_abs;       %取变换后的幅度
    %mtmp = mean(tmp_abs);    kurtosis= sum((tmp_abs-mtmp).^4)/sum((tmp_abs-mtmp).^2)%计算峰态
    if(maxAm < max(tmp_abs))
        frt = tmp;%输出FRFT变换后的值
        [maxAm,uOpt]=max(tmp_abs);       %当前最大点在当前域的横坐标点
        pOpt=pSel(k);                %当前最大值点的阶数a
    end
end

%% 调试用的语句
% subplot(3,1,1);plot(real(x),'.-');title(['angle = ',num2str(pOpt)]);
% subplot(3,1,2:3);imagesc(1:length(x),pSel,G);xlabel('ut');ylabel('angle');axis xy;
% pause(0.05)

end


function y = signalFilterIter(x, ind, thr, maxLen)
% 对输入的频域数据x，从ind处往两边延伸查找到峰值边界，将峰值数据都归0。
% 边界的定义：其幅值小于阈值edgeThr*max且是极小值的点。如果查找到的极值点超过maxLen则放弃。
edgeThr = 0.2; %边缘
Len = length(x);
y = x;%默认都是0
y(ind) = x(ind); maxAbs = abs(x(ind));%计算最大值
%% 往前搜索
absp = maxAbs;
for len = 0:maxLen %注意需要包含0长度点
    indc = mod(ind-len,Len) + 1; %往左边找
    absc = abs(x(indc));
    if maxAbs<absc; maxAbs = absc; end
    if (absc < maxAbs*thr); break; end %到达阈值
    if (absc < maxAbs * edgeThr) && (absc > absp);   end%边界到达条件
    y(indc) = 0;%本节点包含到滤波后的数据
    absp = absc; %记录本节点的幅值
end
%% 往后搜索
absp = maxAbs;
for len = 0:maxLen 
    indc = mod(ind+len,Len) + 1; %往右边找
    absc = abs(x(indc));
    if maxAbs<absc; maxAbs = absc; end
    if (absc < maxAbs*thr); break; end %到达阈值
    if (absc < maxAbs * edgeThr) && (absc > absp);   end%边界到达条件，主要是为了抑制交叉分量
    y(indc) = 0;%本节点包含到滤波后的数据
    absp = absc; %记录本节点的幅值
end

end





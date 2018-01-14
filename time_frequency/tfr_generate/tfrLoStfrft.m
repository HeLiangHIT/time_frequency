function [tfr,ang] = tfrLoStfrft(x,prec,N,h)
%% 局部优化的短时分数阶傅立叶变换计算：[tfr,ang] = tfrStfrft(x,prec,N,h)
% 输入：
%           x: 输入的时域数据，一行或者一列
%           prec: FRFT旋转角度精度
%           N：输出的频域长度，需要>=0
%           h：可选一行或者一列输入的窗函数，需要注意h(0)=1，否则无法恢复信号。
% 输出：
%           tfr：计算得到的STFRFT谱
%           ang：STFRFT在各个时刻的旋转角度，用于将tfr上估计的瞬时频率uc转换为fc


EDGE_REPEAT = 1;

x = x(:);   tLen = length(x);  t=1:tLen;%参数初始化
if (nargin < 1),    error('At least 1 parameter is required.');  end
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
angT = zeros(1,tLen);
% 计算各个时刻的最佳旋转阶数：这时还无需加窗，否则会带来干扰
for it=1:tLen,
    ti= t(it); startT = ti - hlength +1; endT = ti + hlength -1;
    if startT<1; startT = 1;end
    if endT>tLen;endT = tLen;end
    taux = startT : endT;
    xtmp = x(taux,1);% 为了加速可以在这里只传递窗长度的数据到寻找阶数上面
    angT(it) = findOptimalFrft(xtmp,pSel);%plot(real(xtmp))
end
% 对ang进行滤波平滑操作
ang = filterDataSafe(angT);%滤波后比较平滑不易出现TFR波动较大的情况
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
    tfr(indices,it)=x(ti+taux,1).*conj(h(tauh));
    tfr(:,it)=frft(tfr(:,it),ang(it));%计算FRFT
    
end


if (nargout==0),
    tfrqview(abs(tfr).^2,x,t,'tfrstft',h);
end
end

function [pOpt] = findOptimalFrft(x,pSel)
% 查找pSel中对x信号的最佳旋转阶数的FRFT变换
% 返回最佳旋转阶数pOpt

G=zeros(length(pSel),length(x));	%不同阶数的变换结果保存
maxAm=0;        %记录最大频点
for k=1:length(pSel)
    tmp=fracft(x,pSel(k));      %分数阶傅立叶变换
    G(k,:)=abs(tmp(:));       %取变换后的幅度
    if(maxAm < max(abs(tmp(:))))
        [maxAm,uOpt]=max(abs(tmp(:)));       %当前最大点在当前域的横坐标点
        pOpt=pSel(k);                %当前最大值点的阶数a
    end
end

%% 调试用的语句
% subplot(3,1,1);plot(real(x),'.-');title(['angle = ',num2str(pOpt)]);
% subplot(3,1,2:3);imagesc(1:length(x),pSel,G);xlabel('ut');ylabel('angle');axis xy;
% pause(0.05)

end

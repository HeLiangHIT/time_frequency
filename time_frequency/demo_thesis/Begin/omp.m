function [hat_y,r_n]=omp(s,T,N,K)
%  OMP算法的的函数: hat_y=omp(s,T,N)
%  s-测量；T-观测矩阵（恢复矩阵）；N-向量大小； K-信号稀疏度
% 初次实现参考文献：Joel A. Tropp .et
%  Signal Recovery From Random Measurements Via Orthogonal Matching
%  Pursuit，IEEE TRANSACTIONS ON INFORMATION THEORY, VOL. 53, NO. 12,
%  DECEMBER 2007.
% 第1次改进：每次输出残差，这样就可以用于多分量信号的逐次匹配提取了
% （对于每一个分量可以根据信号分类形式输入不同的恢复矩阵T），每提取出一个分量后输出的残差用于提取下一个分量。



Size=size(T);                                     %  观测矩阵大小
M=Size(1);                                        %  测量
hat_y=zeros(1,N);                                 %  待重构的谱域(变换域)向量                     
Aug_t=[];                                         %  增量矩阵(初始值为空矩阵)
r_n=s;                                            %  残差值

for times=1:K;                                    %  迭代次数（不会超过稀疏性）
    for col=1:N;                                  %  恢复矩阵的所有列向量
        product(col)=abs(T(:,col)'*r_n);          %  恢复矩阵的列向量和残差的投影系数(内积值) 
    end
    [val,pos]=max(product);                       %  最大投影系数对应的位置
    Aug_t=[Aug_t,T(:,pos)];                       %  矩阵扩充
    T(:,pos)=zeros(M,1);                          %  选中的列置零（实质上应该去掉，为了简单我把它置零）
    aug_y=(Aug_t'*Aug_t)^(-1)*Aug_t'*s;           %  最小二乘，使残差最小，其实这里保留了相位相关信息
    r_n=s-Aug_t*aug_y;                            %  残差
    pos_array(times)=pos;                         %  纪录最大投影系数的位置
    
    if (abs(aug_y(end))^2/norm(aug_y)<0.05)       %  自适应截断误差（***需要调整经验值）
        break;
    end
end

hat_y(pos_array)=aug_y;                           %  重构的向量

end
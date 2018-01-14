function linesCon = linesConnect(linesOrg,expDis)
%  根据端点距离和端点梯度进行拼接，只能用于经过curveModify拟合修正后的线段信息
% 如果要直接用于linesSimplify处理后的操作，需要将conMatrix下的linesOrg{k}.line()修改为linesOrg{k}()，因为cell结构不同。

% 缺点待改进：限制时间重叠的时候只能连接一个IF片段，即右边的IF片段不能同时连接左边的两个IF片段，否则就会出错。
% 判据修改：一个IF的一端只能连接一个IF片段，存在多个可以连接的时候需要判断哪一个最优（选择最近的一个或者最佳匹配的一个）


% 检查输入，只有一条线则无需连接
if length(linesOrg)<2;
%     return linesOrg;
end

%% 计算连接矩阵
con = conMatrix(linesOrg,expDis);
conVec = transMatrix2Struct(con);

%% 连接曲线
for k=1:length(conVec)
    linesCon{k} = [];
    for m = 1:length(conVec{k})
        line = linesOrg{conVec{k}(m)}.line;%获取曲线
        linesCon{k} = [linesCon{k};line];%曲线拼接
    end
end

end

function con = conMatrix(linesOrg,expDis)
%% 计算邻接矩阵conn，当某两个线段可以连接时他们的交点坐标为1

% 基本参数
interNum = 1;%允许交叉的最大点数，这个参数和之前的curveModify延伸有关
% expDis = 50;%期望的间隔距离，超过这个距离则极有可能被判为不连接
% 针对LxLS时选择100，针对SS选择40较好。
floEps = 0.1;%梯度低于这个值可以认为是水平线段

con = eye(length(linesOrg));%连接矩阵，如果可以连接则对应元素将被置1
for k1 = 2:length(linesOrg)
    for k2 = 1:(k1-1)%只需要两两判断
        %计算曲线k1和k2的可连接性
        x1 = linesOrg{k1}.line(:,1);x2 = linesOrg{k2}.line(:,1);
        if length(intersect(x1,x2))>interNum%存在过多交叉值，不可能是连接的
            continue;
        end
        y1 = linesOrg{k1}.line(:,2);y2 = linesOrg{k2}.line(:,2);
        %plot(x1,y1,'r.-',x2,y2,'b.-');legend('k1','k2');
        if x1(1)<x2(1)% k1在前
            interVec = [x2(1) - x1(end), y2(1) - y1(end)];%间隔梯度
            preVec = [1,y1(end) - y1(end-1)];%前段梯度
            proVec = [1,y2(2) - y2(1)]; %后段梯度
        else %k2在前
            interVec = [x1(1) - x2(end), y1(1) - y2(end)];%间隔梯度
            preVec = [1,y2(end) - y2(end-1)];%前段梯度
            proVec = [1,y1(2) - y1(1)]; %后段梯度
        end
        
        if abs(proVec(2))<floEps & abs(preVec(2))<floEps & interVec(1)<5
            %可以认为是【跳频信号】连接处理，但是此处还没涉及到这个情况，暂不处理
        end
        
        interAbs = norm(interVec,'fro');%间隔距离
        interVec = interVec/interVec(1);%间隔梯度，归一化为x坐标1方便后面的判断
        if (proVec(2)*preVec(2)<0 | interVec(2)*proVec(2)<0 | interVec(2)*preVec(2)<0 ) & ...
                (abs(proVec(2))>2*floEps | abs(preVec(2))>2*floEps | abs(interVec(2))>2*floEps)
            continue;%这种情况不允许连接，有非水平梯度但是方向不一样
            %判据可以修改为：
            %min([proVec(2)*preVec(2),interVec(2)*proVec(2),interVec(2)*preVec(2)])<0&max(abs([proVec(2),preVec(2),interVec(2)]))>2*floEps
        end
        %cor=min(min(corrcoef([interVec;preVec;proVec]')))%%三个向量的相关系数，只有正负1，不适合用作判别
        %计算相似性
        maxdif = max(abs([interVec(2) - preVec(2), interVec(2) - proVec(2), preVec(2) - proVec(2)]));
        maxVec = max(abs([interVec(2), proVec(2), preVec(2)]));
        rel = expDis/interAbs * maxVec/maxdif; %可连接性与interAbs成反比，与maxdif成反比
        %rel越大则两个线段越有可能连接
        if rel>1
            con(k1,k2) = 1;%k1和k2应该连接
        end
    end
end

end


function conV = transMatrix2Struct(con)
% 将输入的con连接矩阵转换为cell向量，方便曲线的连接
[col,raw] = find(con==1);

if length(col)<1%并没有相交的
    conV = num2cell(1:length(con));
    return;
end

num = 1;
while length(raw) >0
    conV{num} = [col(1),raw(1)];
    col(1) = [];%删除元素
    raw(1) = [];
    flag = 0;
    while flag == 0%一直到不存在可以合并的为止
        flag=1;%寻找之前先默认没有
        k = 1;
        while k <= length(raw)
            setT = [col(k),raw(k)];%该行的连接
            if sum(ismember(setT,conV{num}))>0
                conV{num} = [conV{num},setT];%存在则合并
                col(k) = [];
                raw(k) = [];
                %k = k-1;%matlab循环的不规范导致需要修正
                flag=0;%存在可以合并的
            else
                k = k+1;
            end
        end
    end
    num = num+1;
end

for k=1:length(conV)
    conV{k} = unique(conV{k});%上面合并时有重复的数字
end

end











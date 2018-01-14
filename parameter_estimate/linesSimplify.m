function linesSim = linesSimplify(linesOrg)
%% 根据输入的曲线lineeOrg进行去重操作，主要原理是：
% 对于IfLineSegmentDetection检测到的lines，由于是轮廓所以对某个很坐标其纵坐标值可能存在很多相同值，针对这种情况需要去除相同的值。
% 另外需要分别判断其各个横坐标对应的纵坐标有没有可能是多条线段的！如果是，则需要抛弃该总的线段，并标记错误！

num=1;%正确的线段下标
for k = 1:length(linesOrg)
    %% 提取各个存在的横坐标值
    x = linesOrg{k}(:,1);
    y = linesOrg{k}(:,2);
    xu = sort(unique(x));%找出x中的众数，这里的特性是：xu肯定连续
    if length(xu)<5
        continue;
    end
    yut = {};yu = [];
    %% 取所有横坐标对应的纵坐标值：unique+sort以方便后面的操作
    for m = 1:length(xu)
        yu_temp = unique(y(x==xu(m)));%找到所有x=xu(m)的y值
        yut{m} = sort(yu_temp);%先取出各个xu对应的yu值
    end
    %% 判断曲线是否需要存在一个x对应多个值的情况，存在则标记错误
    err = 0;%无错误
    for m = 1:length(yut)
        if length(yut{m}) ==1%只有一个值
            yu(m) = yut{m};
        elseif length(yut{m}) >= yut{m}(end) - yut{m}(1)+1%连续相邻，由于前面unique了，大于的可能性不大
            yu(m) = mean(yut{m});
        else %其它情况：就是离散的纵坐标值，对应多条并行线段，标记错误
            if m==1
                yu(m) = min(yut{m});%取最低一条线段
            else
                try
                    ind = floor(min(abs(yut{m} - yu(m-1))));%最靠近前一个值的坐标点
                    yu(m) = yut{m}(ind);%取最靠近前一个值的点
                catch
                    yu(m) = yut{1}(1);%取第一个点
                end
            end
            %fprintf('线段-%d-解析可能存在错误，包含多个线段，请修正阈值重新检测该线段！\n',k);
            err = 1;%有错误
            %break;
        end
    end
%     if err==0%舍弃有错误的线段
        linesSim{num} = [xu,yu'];%组合线段
        num = num+1;
%     end
%     plot(xu,yu','b.-'); hold on; grid on;
end

end
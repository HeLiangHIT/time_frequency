%% 测试for循环的执行效率

N = 80;

tic
sum = 0;
for k1 = 1:N
    for k2=1:N
        for k3=1:N
            for k4=1:N
                sum = sum+1;
            end
        end
    end
end

toc%N=100时就需要分钟级别的运行时间了！不可行！
function [t,s]=cosSignalGen(f,p,a,fs,N)
% [t,s]=cosSignalGen(f,p,a,fs,N)
% 产生多个正弦信号的叠加，输入f/p/a表示各个频点/初始相位(弧度)/幅度，fs是采样频率，N是采样点数

t=(0:1:N-1)/fs;%采样时长
s=zeros(1,length(t));
for k=1:length(f)
    s=s+a(k)*sin(2*pi*t*f(k)+p(k));%循环叠加正弦信号
end

end
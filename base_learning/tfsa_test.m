%% TFSA工具箱测试
% 在tfsa6界面窗口中测试的所有结果都可以转换为代码实现，重点方法是：
% 1）Tfsa6>>Tools>>quad..TF anal…>>可以选择B-distradition，然后看到需要给他输入的参数基本上有窗长度=127、时间分辨率=1、参数beta=0.1、FFT长度128。
% 2）之后到安装目录下找到quadtfd查看帮助（可以界面输入后按F1），发现其调用方法是tfd = quadtfd( signal, lag_window_length, time_res, kernel [, kernel options] [,fft_length ] );%其中kernel为’b’时表示该分布，需要的参数为beta，因此就可以根据界面上的参数来计算了。


%% 信号产生
clear all;clc; close all;
N=512;
t=1:N;
s1=gsig('lin',0.1,0.4,N,1);%产生LFM的实数信号
figure,plot(t,s1); axis tight;
s2=gsig('cubic',0.1,0.4,N,0);%产生LFM的实数信号
figure; tfrspwv(s2);%TFTB工具箱函数代替用着
s3=gsig('step',0.1,0.4,N,0,8);%产生LFM的实数信号
figure; tfrspwv(s3);
s4 = gsig( 'sin', 0.25, 0.02, 128, 1, 1);
figure; tfrspwv(s4);
s5=analyt(s1);%产生解析信号
figure; tfrspwv(s5);


%% 二次时频分析
tfd = quadtfd(s4, 127, 1, 'emb', 0.1, 0.1);%alpha=0.1,beta=0.1
tfr = tfrspwv(s4);%用作对比的效果
figure('Position',[50,50,1200,600]); 
subplot(121);imagesc(tfd);title('Extended Modified B-distribution');
subplot(122);imagesc(tfr);title('SPWVD')
%演示kernal
for b=logspace(-3,0,20)
    for a=logspace(-3,0,20)
        bk = quadknl( 'emb', 127, 1 ,a, b);
        surf(bk), pause(0.01)
    end
end
%时频分布绘制：事实上使用该绘制方法确实可以让分布更好看！
% 但是实际上分布还是不那么完美！！
p = tfsapl( s4, tfd);


%% 多次时频分布
tfd6 = pwvd6(s2,127,1,8);%插值是8倍的
tfd4 = pwvd4(s2,127,1);
figure('Position',[50,50,1200,600]); 
subplot(121);imagesc(tfd6);title('6r-WVD');
subplot(122);imagesc(tfd4);title('4r-WVD')

%% 模糊函数
am = ambf(s2,1,127);
figure, surf(abs(am))

%% 瞬时频率估计
s = s3;
if1 = zce( s, 64);plot(t,if1,'b.-'); hold on
if2 = wvpe(s, 127, 1);plot(t,if2,'r.-');
if3 = pwvpe(s,127,1,8);plot(t,if3,'k.-');
if4 = rls(s,0.5);plot(t,if4,'bx-');
if5 = pde(s,2);plot(t,if5,'rx-');
if6 = lms(s,0.5);plot(t,if4,'kx-');
legend('zce','wvpe','pwvpe','rls','pde','lms');axis tight; xlabel('t');ylabel('IF')
%事实上界面上貌似还有其它方式、



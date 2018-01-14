%% 复杂信号的分析
clear all; close all;clc

%% 1、选择信号的频率分析方式
[s,s_itfr] = signal_gen_my();%指定信号产生
itfd = s_itfr';%配合BD谱显示方法
figure;contour(itfd);% colormap('hot');
title('理想时频分布');%理想时频分布的查看
xlabel('f/Hz'),ylabel('t/s')
% % load test_signal

% tfd = quadtfd( s, 127, 1, 'mb',0.08);%计算BD谱
% figure; p = tfsapl( s, tfd); %wfall(tfd')



%% curvelet 分析：等效去噪效果
% tfr = tfrspwv(s);%【效果还行】
% tfr(isnan(tfr))=0;
% subplot(121);imshow(abs(tfr),[]);colormap('hot');
% subplot(122);
% C = fdct_usfft(tfr);
% for k1 = 1:length(C)
%     for k2 = 1:length(C{k1})
%         tmp = C{k1}{k2};
% %         imshow(abs(tmp),[]); colormap('hot');pause(0.05)
%         tmp(abs(tmp)<15)=0;
%         C{k1}{k2} = tmp;
%     end
% end
% tfrr = ifdct_usfft(C,0);
% imshow(abs(tfrr),[]); colormap('hot');

%% 其它时频分布
% figure;tfrbj(s);%跳频和SIN调频错误，而且交叉部分干扰严重
% figure;tfrbud(s);%分辨率不足
% figure; tfrcw(s);%同上
% figure;tfrdfla(s);%分辨率足够，干扰项太多
% figure;tfrbert(s);%分辨率足够，干扰项太多
% figure;tfrgabor(s);%分辨率太差，不可用
% figure;tfrgrd(s);%模糊太严重，跳频信号丢失
% figure;tfrppage(s);%不清晰，纵向干扰强
% figure;tfrparam(s);%不可行
% tfrpmh(s);%纵向干扰太强
% tfrpwv(s);%干扰项太多
% tfrrgab(s);%损失的频率细节太多
% tfrridb(s);%跳频成分损失的细节太多，SIN调频变形严重
% tfrridbn(s);%和上一个差不多，LFM信号较好
% tfrridt(s);%比上一个稍差
% tfrrpwv(s);%跳频信号丢失所有细节，干扰较多
% tfrrsp(s);%SP中可看出大概分布，R后丢失跳频细节
% tfrrspwv(s);%【SPWVD还行】
% tfrscalo(s);%效果一般
% tfrspaw(s);%干扰项太多
% tfrstft(s);%【效果还好】
% tfrzam(s);%分辨率比前者高，但是细节丢失较多
% tfrspwv(s);%【效果还行】

% Gt = kaiser(31,1);%beta越大能力越集中
% Hf = kaiser(15,1);
% tfrrspwv(s,1:length(s),length(s),Gt,Hf);%优于默认的汉宁窗效果


TFD_AFS = tfrAFS(s);figure;imagesc(TFD_AFS);axis xy
TFD_ADTFD = tfrADTFD(s,3,12,82);figure;imagesc(TFD_ADTFD);axis xy



clc; clear;close all;
%% 实际癫痫病的脑电信号分析
% tfrADTFD 对各种分量的瞬时频率都比较敏感，但是这也导致它对噪声更敏感！

% Input Signal
t=0:255;
load Seizure_signal;     % Seizure sinal  Md.A


display('Spectrogram');
spec = quadtfd( x, length(x)-1, 1, 'specx', 95, 'hamm',256);
figure; tfsapl(x,spec,'GrayScale','on', 'Title', 'Spectrogram');

display('Extended Modified B distribution');
TFD_EMBD=quadtfd(x,155,2,'emb',0.05,0.15,length(x));
figure; tfsapl(x,TFD_EMBD,'GrayScale','on', 'Title', 'EMBD');

display('Compact Kernel distribution');
TFD_CKD=tfrCKD(x);
TFD_CKD(TFD_CKD<0)=0;
figure; tfsapl(x,real(TFD_CKD),'GrayScale','on','Title','Compact Kernel Distribution');

display('Adaptive fractional Spectrogram');
TFD_AFS=tfdAFS(hilbert(x));
figure; tfsapl(x,TFD_AFS,'GrayScale','on','Title','Adaptive fractional Spectrogram' );

display('AOK-TFD');
I_max_new = tfrAOK(x);
TFD_AOK=real(I_max_new);
figure; tfsapl(x,TFD_AOK,'GrayScale','on','Title','AOK-TFD');

display('Adaptive direction TFD');
TFD_ADTFD = tfrADTFD(x, 3,8,82);
TFD_ADTFD(TFD_ADTFD<0)=0;
TFD_ADTFD=imresize(TFD_ADTFD,[length(x) length(x)]);
figure; tfsapl(x,TFD_ADTFD,'GrayScale','on','Title', 'Adaptive direction TFD');








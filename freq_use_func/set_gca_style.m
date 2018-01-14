function set_gca_style(winSize, figType)
% 设置窗口大小和字体等以便可以粘贴到word中

if(nargin<1 || isempty(winSize)) winSize=[10,8]; end
axis tight;box on; grid on;%title('')%通常word里面不需要title

FONT_TYPE='Times-Roman';
FONT_SIZE=10.5;
set(gca,'FontName',FONT_TYPE,'FontSize',FONT_SIZE,'color','white');
%     set(gca,'ytick',[0:0.04:0.2]);
%     set(gca,'xtick',[0:40:180]);    
% % 关于图像占满全屏以方便拷贝的问题，可以采用一下两种方案之一：
% imshow(abs(TFD_ADTFD),[],'border','tight','initialmagnification','fit')
% set(gca, 'position', [0 0 1 1 ]);

% set(gcf,'WindowStyle','normal');%防止修改后不让更改位置
set(gcf,'unit','centimeters','position',[5 5 winSize(1) winSize(2)],'color','none')
% print -dmeta %复制矢量图

% 图形无需坐标系且需要占满全屏
if(nargin>1 && ischar(figType)) %为了兼容之前的程序增加判断
    switch(lower(figType))
        case 'img';
            axis xy; axis off;set(gca, 'position', [0 0 1 1 ]);colormap('hot');
        otherwise;
    end
end

end


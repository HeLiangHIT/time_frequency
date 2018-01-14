
function [individual_tracks,tf_tracks]=tracks_LRmethod_my(tf,delta_time,delta_limit,min_length,LOWER_PRCTILE_LIMIT)
%-------------------------------------------------------------------------------
% 图像形态学处理相关算法的IF估计
% 修正之处：连接区域允许大于2点的连接？

if(nargin<2 || isempty(delta_time)) delta_time=2; end
if(nargin<3 || isempty(delta_limit)) delta_limit=4; end
if(nargin<4 || isempty(min_length)) min_length=[]; end
if(nargin<5 || isempty(LOWER_PRCTILE_LIMIT)), LOWER_PRCTILE_LIMIT=95; end


%---------------------------------------------------------------------
% remove all energy below this percentile:
% (added 2016, JOT)
%---------------------------------------------------------------------
tf(tf<prctile(tf(tf>0),LOWER_PRCTILE_LIMIT))=0;


% Generate binary image representing local maxima
tf=tf';
a = size(tf);
im_bin1 = zeros(a).';
for kk = 1:a(2)
    q1 = tf(:,kk);
    u = diff(q1);
    uu = q1;
    zc_max =[];
    count_max = 1;
    for zz = 1:(length(u)-2)
        if u(zz)>=0
           if u(zz+1)<0
            zc_max(count_max) = zz;
            count_max = count_max+1;
        end
    end
    end
    q2 = zeros(1,a(1));
    q2(zc_max+1) = 1;
    im_bin1(kk,:) = q2;
    clear q* z* c* ref
end

clear u uu kk zz ref tf

% Apply the edge linking algorithm to the binary image.
% Set up the search region based on the size of the separable kernel.
M=delta_limit;
ref = [0:M+1 -1:-1:-(M+1)];
[val, idx] = sort(abs(ref));
nref = ref(idx);
sch = [];
for k = 1:delta_time
    sct = [k*ones(1,length(nref));nref];
    sch = [sch,sct];% 产生自定义的允许时间-频率跳变范围的搜索邻域
end

% Search binary image for nonstationary components:
[individual_tracks, tf_tracks] = edge_link(im_bin1, min_length, sch);
end




function [el,ei] = edge_link(imb, len, sch)
% Edge linking for binary images.
%
%  [el,ei] = edge_link(imb, len, sch)
%
% This functions links together sequences of 1's in a binary image. It is a 
% modified version of the edge linking algorithm presented in 
% Farag A, Delp E, Edge linking by sequential search. Pattern
% Recognition. 1995; 28: 611--33. The modifications include an user defined
% search region.
%
% INPUT: imb - the binary image under analysis
%               len - the minimum length of an edge
%               sch - a matrix defining the search region
%
% OUTPUT: el - a Lx1 cell array containing vectors that define the L detected 
%                          edges in the image. Each cell contains the x and y co-ordinates 
%                          of each linked edge. 
%                   ei - is an image with all linked edge projected onto a
%                          blank image.
%
% Notes: uses the link_edges.m function
%
% Nathan Stevenson
% NBRG, September 2011

% Initialise binary image
N = size(imb);
M1 = max(abs(sch(2,:)));
M2 = max(abs(sch(1,:)));
imb1 = imb;
clear imb;
imb = zeros(N(1)+2*M2, N(2)+2*M1);
imb(M2+1:N(1)+M2, M1+1:N(2)+M1) = imb1; 
M = size(imb);

% Perform edge-inking procedure
el = cell(1); count = 1;
for ii = 1:M(1);
    for jj = 1:M(2);
        if imb(ii,jj)==1           
            [ifest, imb]= link_edges(imb, jj, ii, sch, M1, M2);
            if length(ifest)>len
                el{count} = ifest';
                count = count+1;
            end
        end
    end
end

clear ii jj

% Generate binary image of linked edges
ei = zeros(N);
for ii = 1:length(el)
    el1 = el{ii};
    for jj = 1:size(el1,1)
       ei(el1(jj,1), el1(jj,2)) =1; 
    end
    clear el1
end

end


function [ml, imbm] = link_edges(imb, rx, ry, sch, M1, M2)
% Link edges 
%
% [ml, imbm] = link_edges(imb, rx, ry, sch, M1, M2)
%
%This function tracks a edge through the image via a particular
% neighbourhood search pattern
%
% INPUTS: imb - the binary image to be linked
%                  [rx, ry] - the starting point of the component search
%                  sch - the user-defined search region
%                  [M1, M2] - the size of the binary image
%
% OUTPUTS: ml - the [x,y] co-ordinates of the linked component
%                     imbm - the updated binary image with the linked
%                                   component removed.
%
% UQCCR, level 04
% Nathan Stevenson
% August 2008

c1 = 1; 
mlx = rx;
mly = ry;
flag = 1;
imb(ry,rx)=0;
while flag==1
    for kk = 1:length(sch)
           x = mlx(c1)+sch(2,kk);
           y = mly(c1)+sch(1,kk);
           ref(kk) = imb(y, x);
    end
    qq = find(ref==1, 1);
    if isempty(qq)~=1        
        rx = mlx(c1)+sch(2,qq); 
        ry = mly(c1)+sch(1,qq);
        imb(ry,rx)=0;
        c1 = c1+1;
        mlx(c1) = rx; mly(c1) = ry;
        flag = 1;
    else
        flag = 0;
    end
    clear qq ref
end
ml = [mly-M2 ; mlx-M1];
imbm = imb;

end

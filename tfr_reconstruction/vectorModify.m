function [beta1fix,beta2fix] = vectorModify(beta1,beta2)
% 根据公式8修正梯度向量的beta1和beta2
% 修正的方向是向左，论文上是向右，也许是因为图像坐标系方向不同导致旋转方向不同吧，但应该不影响结论。

beta1fix = zeros(size(beta1));beta2fix = zeros(size(beta2));%初始化

% % 13象限的矢量修正
% [quad13] = find(beta1.*beta2>=0);
% beta1fix(quad13) = beta2(quad13);
% beta2fix(quad13) = -beta1(quad13);
% % 24象限的矢量修正
% [quad24] = find(beta1.*beta2<0);
% beta1fix(quad24) = -beta2(quad24);
% beta2fix(quad24) = beta1(quad24);

% 12象限的矢量修正
quad12 = find(beta1>=0);
beta1fix(quad12) = beta2(quad12);
beta2fix(quad12) = -beta1(quad12);
% 34象限的矢量修正
quad34 = find(beta1<0);
beta1fix(quad34) = -beta2(quad34);
beta2fix(quad34) = beta1(quad34);

end


% Plot the curves extracted via curve_ext or curve_ext_multi
%
%  hc = plot_ext_curves(t, x, Tx, fs, Cs, Es, opt, clwin)
%
% Input:
%  t, x, opt: same as input to synsq_cwt_fw/iw
%  Tx, fs, clwin: same as input to curve_ext_multi
%  Cs, Es: same as output of curve_ext_multi
% Output:
%  hc: Object handle for the resulting figure
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function hc = plot_ext_curves(t, x, Tx, fs, Cs, Es, opt, clwin)

if nargin<8, clwin = 4; end
if nargin<7, opt = struct(); end

if ~isfield(opt, 'markers')
  opt.markers = {'+','o','*','x','s','d','^','v','>','<','p','h' };
end

Nc = length(Es);
[na, N] = size(Tx);

assert(N == length(t));
assert(N == length(x));
Nc = length(Es);

% Reconstruct the curve signals
xrs = curve_ext_recon(Tx, fs, Cs, opt, clwin);

hca = gcf;

% Plot everything
if isfield(opt, 'hc'),
    hc(1) = opt.hc(1);
    subplot(hc(1));
else
    hc(1) = subplot(2, 1, 1);
end

% Plot Tx
tplot(Tx, t, fs, opt);
% Set T-axis properly
axis tight;
xlabel('t');
ylabel('f');
title('Extracted Contour(s)');

% Plot the contours
hold on;
cpl=plot_markers(t, log2(fs(Cs)), opt.markers, '--k', 'LineWidth', 2);
legend(cpl, cellfun(@(j) {sprintf('k=%g', j)}, num2cell(1:Nc)));

if isfield(opt, 'hc')
    hc(2) = opt.hc(2);
    subplot(hc(2));
else
    hc(2) = subplot(2, 1, 2);
end

% % Plot both original signal and extracted contour
lcs = plot(t, x, 'k'); hold on;
lcs = [lcs plot_markers(t, xrs, opt.markers, '--k', 'LineWidth', 1)];

axis tight;
xlabel('t');
ylabel('x_c(t)');
grid on;
title('Reconstruction of Extracted Contour');
xcleg = arrayfun(@(j) {sprintf('x_%g(t)', j)}, 1:Nc);
legend(lcs, 'x(t)', xcleg{:});

linkaxes([hc(1) hc(2)], 'x');
zec = zoom(hca);
set(zec, 'RightClickAction', 'InverseZoom');
setAxesZoomMotion(zec, hc(1), 'vertical');
setAxesZoomMotion(zec, hc(2), 'horizontal');
set(zec, 'Enable', 'on');

end
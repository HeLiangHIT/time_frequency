% function hc = plot_ext_curves_cmp(t, xs, Tx, fs, Cs, Es, opt, clwin)
%
% Plot the curves extracted via curve_ext or curve_ext_multi
% Compare them to "true" component curves as well as able to.
%
%  hc = plot_ext_curves_cmp(t, xs, Tx, fs, Cs, Es, opt, clwin)
%
% Input:
%  t, opt: same as input to synsq_cwt_fw/iw/tplot
%  xs: array vector of individual components to compare against
%  Tx, fs, clwin: same as input to curve_ext_multi
%  Cs, Es: same as output of curve_ext_multi
% Output:
%  hc: Object handle for the resulting figure
%
% Examples:
%  See gen_nonunif_fig.m
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function hc = plot_ext_curves_cmp(t, xs, Tx, fs, Cs, Es, opt, clwin)

if nargin<8, clwin = 4; end
if nargin<7, opt = struct(); end

if ~isfield(opt, 'draw_contours')
  opt.draw_contours = true;
end

if ~isfield(opt, 'markers')
  opt.markers = {'+','o','*','x','s','d','^','v','>','<','p','h' };
end

Nc = length(Es);
[na, N] = size(Tx);

assert(N == length(t));
assert(N == length(xs));
Nc = length(Es);
assert(Nc == size(xs,2));

% Reconstruct the curve signals
xrs = curve_ext_recon(Tx, fs, Cs, opt, clwin);

hca = gcf;

% Plot everything
if isfield(opt, 'hc')
    hc(1) = opt.hc(1);
    subplot(hc(1));
else
    hc(1) = subplot(1+Nc, 1, 1);
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
if opt.draw_contours
  lcs = plot_markers(t, log2(fs(Cs)), opt.markers, '--k', 'LineWidth', 0.5);
  legend(lcs, cellfun(@(j) {sprintf('k=%g', j)}, num2cell(1:Nc)));
end

for ci=1:Nc
    if isfield(opt, 'hc'),
        hc(ci+1) = opt.hc(ci+1);
        subplot(hc(ci+1));
    else
        hc(ci+1) = subplot(1+Nc, 1, 1+ci);
    end

    % % Plot both original signal and extracted contour
    % Find most correlated x of xs to this extracted contour
    [Mc,Mci] = max(corr(xrs(:,ci), xs));
    hold on;
    plot(t, xs(:,Mci), '--k', 'LineWidth', 0.5);
    if opt.draw_contours
        plot_markers(t, xrs(:,ci), {opt.markers{1+mod(ci-1,length(opt.markers))}}, ...
                     'k', 'LineWidth', 1);
    else
        plot(t, xrs(:,ci), 'k', 'LineWidth', 1);
    end
    axis tight;
    xlabel('t');
    ylabel(sprintf('x_%g(t)',ci));
    grid on;
    %xcleg = map(@(j) sprintf('x_%g(t)', j), num2cell(1:Nc));
    %legend('x(t)', xcleg{:});
end

linkaxes(hc, 'x');
zec = zoom(hca);
set(zec, 'RightClickAction', 'InverseZoom');
setAxesZoomMotion(zec, hc(1), 'vertical');
setAxesZoomMotion(zec, hc(2:end), 'horizontal');
set(zec, 'Enable', 'on');

end
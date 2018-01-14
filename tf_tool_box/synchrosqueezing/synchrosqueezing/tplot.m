% function [h,opt] = tplot(Tx, t, fs, opt)
% function [h,opt] = tplot(Wx, t, as, opt)
%
% Plots the 2D magnitude of either the synchrosqueezing or
% wavelet transform of signal x via tplot.  Allows for restrictions
% to particular frequency or scale intervals.  Plots boundaries
% past which the transform is no longer accurate.  Scales the
% signal.  Draws pretty ticks on the y-axis.
% 
% Input
%   Tx, t, fs (e.g. output of synsq_cwt_fw, or properly chosen slices)
%     Use opt.style = 'freq'.
%  or
%   Wx, t, as (e.g., output of cwt_fw, or properly chosen slices)
%     Use opt.style = 'scale'.
%
%  opt is a struct of options.  key/value pairs:
%   nticks: number of ticks on y-axis (default: 6)
%   style: 'freq' for synsq output, 'scale' for wavelet output (default: freq)
%   bd: overlay accuracy boundaries (requires opengl/alpha
%       blending) (default = 1, can be 0 or 1).
%   ticklabels: cell of strings with tick labels.  if nonempty,
%       'nticks' is not used.  (default = {}).
%       example: opt.ticklabels = {'1e-2','5e-2','0.1','0.5','1','5','10'}
%   Mquant: quantile for thresholding maximum value (default: .995)
%   Mlog: plot logarithm of absolute values (default = 0)
%   flim: 2-dim array with minimum/maximum frequency plotting
%         constraints (default: [-Inf Inf])
%        
% Output:
%   hs - 2-dim vector of handles to the tplot, and the power plot
%    hs(1) - handle to the tplot axis
%    hs(2) - handle to the 90 degree angled power plot axis
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function [h,opt]=tplot(Tx, t, fs, opt)
    if nargin<4, opt = struct(); end
    if ~isfield(opt, 'nticks'), opt.nticks = 6; end
    if ~isfield(opt, 'style'), opt.style = 'freq'; end % or 'scale'
    if ~isfield(opt, 'bd'), opt.bd = 1; end
    if ~isfield(opt, 'ticklabels'), opt.ticklabels = {}; end
    if ~isfield(opt, 'Mquant'), opt.Mquant = .995; end
    if ~isfield(opt, 'Mlog'), opt.Mlog = 0; end
    if ~isfield(opt, 'flim'), opt.flim = [-Inf Inf]; end

    % % Find frequency axis limits

    if fs(2)>fs(1) % Standard
        flim = [max(opt.flim(1), fs(1)), min(opt.flim(2), fs(end))];
        flimi(1) = find(fs >= flim(1), 1, 'first');
        flimi(2) = find(fs <= flim(2), 1, 'last');
    else % Periodicity
        flim = [max(opt.flim(1), fs(end)), min(opt.flim(2), fs(1))];
        flimi(1) = find(fs >= flim(2), 1, 'last');
        flimi(2) = find(fs <= flim(1), 1, 'first');
    end
       
    % Restrict ourselves to this region
    fs = fs(flimi(1):flimi(2));
    Tx = Tx(flimi(1):flimi(2), :);

    lfs = log2(fs);

    if (opt.Mlog)
      aTx = log(1+abs(Tx));
    else
      aTx = abs(Tx);
    end
    clear Tx;
    
    % Check if on a logarithmic freq scale
    clog = mean(abs(diff(lfs, 2))) < eps*100;
    opt.clog = clog;
    if clog
        imagesc(t, lfs, aTx);
    else
        imagesc(t, fs, aTx);
    end
    h = gcf;
    
    if (fs(2)>fs(1))
        set(gca, 'YDir', 'normal');
    else
        set(gca, 'YDir', 'reverse');
    end

    cM = equantile(nonzeros(aTx), opt.Mquant)+eps;
    if isnan(cM), cM = 0; end
    caold = caxis();
    caxis([caold(1) cM]);

    colormap(gca, 1-hot(512));

    if isempty(opt.ticklabels)
        if clog
            tticks = linspace(min(lfs),max(lfs), opt.nticks);
            opt.ticklabels = arrayfun(@(x){sprintf('%.2g',x)}, 2.^tticks);
        else
            tticks = linspace(min(fs), max(fs), opt.nticks);
            opt.ticklabels = arrayfun(@(x){sprintf('%.2g',x)}, tticks);
        end
    end

    % Set ticks according to tick labels
    ticks = cellfun(@(x)str2num(x), opt.ticklabels);
    if clog
        set(gca, 'YTick', log2(ticks)); % Working on log scale
    else
        set(gca, 'YTick', ticks);
    end
    set(gca, 'YTickLabel', opt.ticklabels);

    % Y tick stuff
    set(gca, 'YTickMode', 'manual');
    set(gca, 'YMinorTick', 'on');
    axis tight;

    % Plot boundary?
    if (opt.bd)
        if findstr(opt.style, 'freq'),
            [Lbdi, Rbdi] = synsq_bd_loc(t, fs);
        elseif findstr(opt.style, 'scale'),
            [Lbdi, Rbdi] = cwt_bd_loc(t, fs);
        else
            warning('Unknown style: %s', opt.style);
            Lbdi = []; Rbdi = [];
        end

        fsbd = [fs(1); fs(:); fs(end)];
        Lbdi = [1; Lbdi(:); 1];
        Rbdi = [length(t); Rbdi(:); length(t)];
        %fsbd = fs(:);
        %Lbdi = Lbdi(:);
        %Rbdi = Rbdi(:);

        %Lp = patch(t(Lbdi), log2(fsbd), 'k');
        %Rp = patch(t(Rbdi), log2(fsbd), 'k');
        linepatch_draw(t(1), t(Lbdi), log2(fsbd), ...
                       'Color', 'k', 'LineStyle', ':');
        linepatch_draw(t(end), t(Rbdi), log2(fsbd), ...
                       'Color', 'k', 'LineStyle', ':');
        %set([Lp Rp], 'FaceAlpha', .25);
        %set([Lp Rp], 'EdgeColor', 'none');

        % Correct for a bug in OpenGL rendering with transparency
        % over an image.  Draw a line at the bottom.
        %bL=line([t(1) t(end)], [log2(fs(1)) log2(fs(1))]);
        %set(bL, 'Color', 'k');

        %hold on;
        %plot(t(Lbdi), log2(fs), 'k');
        %plot(t(Rbdi), log2(fs), 'k');
        %hold off;
    end

    
end

function linepatch_draw(xbd,x,y,varargin)
  % Lines
  nx = length(x);
  x = x(:);
  y = y(:);

  % First add contours
  linesx = zeros(nx, 2);
  linesy = zeros(nx, 2);
  for i=1:nx
    j = 1+mod(i,nx);
    linesx(i,:) = [x(i) x(j)];
    linesy(i,:) = [y(i) y(j)];
  end

  % How many horizontal lines do we want total?
  ntotal = 80;
  nsub = max(1, round(nx/ntotal));

  xsub = x(1:nsub:end);
  ysub = y(1:nsub:end);
  linesx = [linesx; xbd*ones(length(xsub),1) xsub];
  linesy = [linesy; ysub ysub];

  hold on;
  plot(linesx', linesy', varargin{:});
end
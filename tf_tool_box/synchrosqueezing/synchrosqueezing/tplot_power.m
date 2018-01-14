% function hs = tplot_power(Tx, t, fs, opt)
% function hs = tplot_power(Wx, t, as, opt)
%
% Plots the 2D magnitude of either the synchrosqueezing or
% wavelet transform of signal x via tplot.
% Also plots the median power estimate for each frequency/scale on
% the side, scaled to the magnitude of the original signal.
% 
% Input (see help tplot):
%   Tx, t, fs (e.g. output of synsq_cwt_fw, or properly chosen slices)
%     Use opt.style = 'freq'.
%  or
%   Wx, t, as (e.g., output of cwt_fw, or properly chosen slices)
%     Use opt.style = 'scale'.
%
%  Additional options to tplot's opt structure:
%   opt.filter: remove/filter side lobes before estimating
%               power? (values: 1 or 0, default: 1)
%   opt.type: wavelet type (necessary to scale power plots
%             accurately, see help wfiltfn, help cwt_fw)
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
function hs = tplot_power(Tx, t, fs, opt)
  if nargin<4, opt = struct(); end

  if ~isfield(opt, 'type'),
    warning(['tplot_power: opt.type not known, db magnitudes only ' ...
             'accurate up to scale']);
    Css = 1;
  else
    Css = synsq_adm(opt.type);
  end

  [na0, n] = size(Tx);
  hs = zeros(1,2);
  hs(1) = subplot(1,2,1);
  [tmp,opt] = tplot(Tx,t,fs,opt);
  xlabel('t');
  grid on;
  
  % Find frequency axis limits
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
  aTx = abs(Tx); clear Tx;
  fs = fs(flimi(1):flimi(2));
  aTx = aTx(flimi(1):flimi(2), :);

  % Calculate the median of the absolute values, filtered properly.
  [muTx,Lbdi,Rbdi] = synsq_filtered_time_quantile(aTx, t, fs, opt, .5);
  
  mlog2 = @(x) x;
  if opt.clog
      mlog2 = @(x) log2(x);
  end
  
  if (~opt.bd)
      hold on;
      plot(t(Lbdi), mlog2(fs), '--k');
      plot(t(Rbdi), mlog2(fs), '--k');
  end
  
  % Mean of aTx plot
  hs(2) = subplot(1,2,2);
  
  plot(mlog2(fs), 10*log10(1/Css*muTx));
  axis tight;
  xlim([min(mlog2(fs)), max(mlog2(fs))]);
  %  %ylim([min(10*log10(muTx)), max(10*log10(muTx))]);
  set(gca, 'XTick', cellfun(@(x)mlog2(str2num(x)), opt.ticklabels));
  set(gca, 'XTickLabel', '');
  xlabel('');
  grid on;

  if (fs(2)>fs(1))
      view([90 -90]);
  else
      view([90 90]);
  end
  ylabel('\mu(| . |) [db]');
  
  set(hs(1), 'Units', 'normalized', 'OuterPosition', [0 0 .75 1.05])
  set(hs(2), 'Units', 'normalized', 'OuterPosition', [.75 0 .25 1.05])
end
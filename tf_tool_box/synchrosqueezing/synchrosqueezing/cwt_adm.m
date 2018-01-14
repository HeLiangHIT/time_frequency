% function Cpsi = cwt_adm(type, opt)
%
% Calculate cwt admissibility constant int(|f(w)|^2/w, w=0..inf) as
% per Eq. (4.67) of [1].
%
% 1. Mallat, S., Wavelet Tour of Signal Processing 3rd ed.
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function Cpsi = cwt_adm(type, opt)
    if nargin<2, opt=struct(); end
    switch type
      case 'sombrero',
        if ~isfield(opt,'s'), s = 1; else s = opt.s; end
        Cpsi = (4/3)*s*sqrt(pi);
      case 'shannon',
        Cpsi = log(2);
      otherwise
        psihfn = wfiltfn(type, opt);
        Cpsi = quadgk(@(x) (conj(psihfn(x)).*psihfn(x))./x, 0, Inf);
    end
    
    % Normalize
    Cpsi = Cpsi / (4*pi);
end
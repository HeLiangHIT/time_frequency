% function Css = synsq_adm(type, opt)
%
% Calculate the Synchrosqueezing admissibility constant, the term
% R_\psi in Eq. 3 of [1].  Note, here we multiply R_\psi by the
% inverse of log(2)/nv (found in Alg. 1 of that paper).
%
% 1. E. Brevdo, N.S. Fučkar, G. Thakur, and H-T. Wu, "The
% Synchrosqueezing algorithm: a robust analysis tool for signals
% with time-varying spectrum," 2011.
%
% Uses numerical integration.
%
% Input:
%   type: type of wavelet (see help wfiltfn)
%   opt: options structure (wavelet parameters, see help wfiltfn)
%
% Output:
%   Css: proportional to 2*int(conj(f(w))/w, w=0..inf)
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function Css = synsq_adm(type, opt)
    if nargin<2, opt=struct(); end
    switch type
      % case 'sombrero',
      %   if ~isfield(opt,'s'), s = 1; else s = opt.s; end
      %   Cpsi = (4/3)*s*sqrt(pi);
      % case 'shannon',
      %   Cpsi = log(2);
      otherwise
        psihfn = wfiltfn(type, opt);
        Css = quadgk(@(x) conj(psihfn(x))./x, 0, Inf);
    end

    % Normalization constant, due to logarithmic scaling in wavelet
    % transform
    Css = Css / (sqrt(2*pi)*2*log(2));
end

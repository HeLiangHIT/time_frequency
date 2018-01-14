% function psihfn = wfiltfn(type, opt)
%
% Wavelet transform function of the wavelet filter in question,
% fourier domain.
%
% Input:
%   type: string (see below)
%   opt: options structure, e.g. struct('s',1/6,'mu',2)
%
% Output:
%   anonymous function @(xi) psihfn(xi)
%
% Filter types      Use for synsq?    Parameters (default)
%
% gauss             yes               s (1/6), mu (2)
% mhat              no                s (1)
% cmhat             yes               s (1), mu (1)
% morlet            yes               mu (2*pi)
% shannon           no                --   (NOT recommended for analysis)
% hshannon          yes               --   (NOT recommended for analysis)
% hhat              no
% hhhat             yes               mu (5)
% bump              yes               s (1), mu (5)
%
% Example:
%  psihfn = wfiltfn('bump', struct('mu',1,'s',.5));
%  plot(psihfn(-5:.01:5));
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function psihfn = wfiltfn(type, opt)
    switch type
      case 'gauss',
        % Similar to morlet, but can control bandwidth
        % can be used with synsq for large enough mu/s ratio
        if ~isfield(opt,'s'), s = 1/6; else s = opt.s; end
        if ~isfield(opt,'mu'), mu = 2; else mu = opt.mu; end
        psihfn = @(w) 2.^(-(w-mu).^2/(2*s^2));
      case 'mhat', % mexican hat
        if ~isfield(opt,'s'), s = 1; else s = opt.s; end
	psihfn = @(w) -sqrt(8)*s^(5/2)*pi^(1/4)/sqrt(3)*w.^2.*exp(-s^2*w.^2/2);
      case 'cmhat', 
        % complex mexican hat: hilbert analytic function of sombrero
        % can be used with synsq
        if ~isfield(opt,'s'), s = 1; else s = opt.s; end
        if ~isfield(opt,'mu'), mu = 1; else mu = opt.mu; end
        psihfnshift = @(w)2*sqrt(2/3)*pi^(-1/4)*s^(5/2)*w.^2.*exp(-s^2*w.^2/2).*(w>=0);
        psihfn = @(w) psihfnshift(w-mu);
      case 'morlet',
        % can be used with synsq for large enough s (e.g. >5)
        if ~isfield(opt,'mu'), mu = 2*pi; else mu = opt.mu; end
        cs = (1+exp(-mu^2)-2*exp(-3/4*mu^2)).^(-1/2);
        ks = exp(-1/2*mu^2);
        psihfn = @(w)cs*pi^(-1/4)*(exp(-1/2*(mu-w).^2)-ks*exp(-1/2*w.^2));
      case 'shannon',
        psihfn = @(w)exp(-i*w/2).*(abs(w)>=pi & abs(w)<=2*pi);
      case 'hshannon',
        % hilbert analytic function of shannon transform
        % time decay is too slow to be of any use in synsq transform
        if ~isfield(opt,'mu'), mu = 0; else mu = opt.mu; end
        psihfnshift = @(w)exp(-i*w/2).*(w>=pi & w<=2*pi).*(1+sign(w));
        psihfn = @(w) psihfnshift(w-mu);
      case 'hhat', % hermitian hat
        psihfn = @(w)2/sqrt(5)*pi^(-1/4)*w.*(1+w).*exp(-1/2*w.^2);
      case 'hhhat',
        % hilbert analytic function of hermitian hat
        % can be used with synsq
        if ~isfield(opt,'mu'), mu = 5; else mu = opt.mu; end
        psihfnshift = @(w)2/sqrt(5)*pi^(-1/4)*(w.*(1+w).*exp(-1/2*w.^2)) .* (1+sign(w));
        psihfn = @(w) psihfnshift(w-mu);
      case 'bump',
        if ~isfield(opt,'mu'), mu = 5; else mu = opt.mu; end
        if ~isfield(opt,'s'), s = 1; else s = opt.s; end
        psihfnorig = @(w)exp(-1./(1-w.^2)) .* (abs(w)<1);
        psihfn = @(w) psihfnorig((w-mu)/s);
      otherwise
        error('Unknown wavelet type: %s', type);
    end % switch type
end

%       case 'daub',
%         %
%         % Construction of such filters follows from Mallat
%         % Eq. (7.140), where g is given by Mallat Eqs. (7.53) and
%         % (7.68) .  Note that these are DTFT equations.
%         %
%         if nargin<4,
%             a = 2; % Dyadic scales
%             p = 2; % Daubechies-2 wavelets (2 vanishing moments)
%             j = 2*(ceil(log(N)/log(2))-1); % Which scale?
%         else
%             a = opt.a;
%             p = opt.p;
%             j = opt.j;
%         end
%         L = ceil(log(N)/log(2));
%         assert(j>=L);

%         [h,g,rh,rg] = daub(2*p);
%         hmat = repmat(h(end:-1:1)', 1, N);

%         % h^(w) and g^(w)
%         hh = @(wp) sum(hmat .* exp(-i*[0:2*p-1]'*wp));
%         gh = @(wp) exp(-i*wp) .* conj(hh(wp+pi));

%         % Calculate g^(a^{j-L-1} w) prod_{k=0}^{j-L-2} h^(a^k w)
%         psih = gh(a^(j-L-1) * w);
%         for k=0:(j-L-2), psih = psih .* hh(a^k * w); end

%         % TODO -- why is this necessary?
%         %psih = -psih;

%         return;

%       case 'symm', % TODO - make a wfilt_qmf for this
%         if nargin<4, p = 2; else p = opt.p; end
%         [h,g,rh,rg] = symmlets(p);
%         psih = zeros(size(W));
%         for pn=1:p, psih = psih + rg(pn)*exp(-i*(pn-1)*W); end

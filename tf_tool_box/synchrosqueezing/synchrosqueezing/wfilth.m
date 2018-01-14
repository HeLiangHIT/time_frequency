% function [psih,dpsih,xi] = wfilt(type, N, a, opt)
%
% Outputs the FFT of the wavelet of family 'type' with parameters
% in 'opt', of length N at scale a: (psi(-t/a))^.
%
% Note that the output is made so that the inverse fft of the
% result is zero-centered in time.  This is important for
% convolving with the derivative(dpsih).  To get the correct
% output, perform an ifftshift.  That is,
%   psi = ifftshift(ifft(psih));
%   xfilt = ifftshift(ifft(fft(x) .* psih));
%
% Inputs:
%   type: wavelet type (see help wfiltfn)
%   N: number of samples to calculate
%   a: wavelet scale parameter (default = 1)
%   opt: wavelet options (see help wfiltfn)
%     opt.dt: delta t (sampling period, default = 1)
%             important for properly scaling dpsih
%
% Outputs:
%   psih: wavelet sampling in frequency domain (for use in fft)
%   dpsih: derivative of same wavelet, sampled in frequency domain (for fft)
%   xi: associated fourier domain frequencies of the samples.
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------
function [psih,dpsih,xi] = wfilth(type, N, a, opt)
    assert(mod(log2(N),1) == 0);
    if nargin<3, a = 1; end
    if nargin<4, opt = struct(); end

    if ~isfield(opt, 'dt'), opt.dt = 1; end

    % When w_k = 1/N * [0, 1, ..., N]
    % The continuous-time frequency variables are xi_k = 2*pi*w_k,
    k = 0:(N-1);
    xi = zeros(1, N);

    % Oppenheim et al., Eq. (10.1), (10.4)
    %   V[k] = V(e^{jw}) @ w=2*pi*k/N, k=0,1,...,N-1
    %   V(e^{jw}) = 1/T sum_{r=-inf}^inf V_c(j (w+2 pi r)/T)
    % where T is the sampling interval and V_c is the FT of v(t)
    %
    % Oppenheim et al., S. 10.2.2, P. 1
    %   Effects of spectral sampling, k=0..N/2, N/2+1..N
    %   are observing xi_k = 2*pi*k/(N*T) for k=0..N/2,
    %                        2*pi*(N-k)/(N*T) k=N/2+1,..,N
    xi(1:N/2+1) = 2*pi/N*[0:N/2];
    xi(N/2+2:end) = 2*pi/N*[-N/2+1:-1];

    psihfn = wfiltfn(type, opt);
    psih = psihfn(a*xi);

    % Sometimes bump gives a NaN when it means 0
    if (strcmpi(type, 'bump')), psih(isnan(psih))=0; end

    % (1/sqrt(a)*psi(n/a))^ = a/sqrt(a) * psi^(n) = sqrt(a) * psi^(n)
    % Mallat, Wavelet Tour 3rd ed, S. 4.3.3
    %
    % Also normalize appropriately
    psih = psih * sqrt(a) / sqrt(2*pi);

    % Center around zero in the time domain
    psih = psih .* (-1).^k;

    % Calculate the fourier transform of the derivative
    if nargout>1,
        dpsih = (i*xi/opt.dt) .* psih;
    end
end % function

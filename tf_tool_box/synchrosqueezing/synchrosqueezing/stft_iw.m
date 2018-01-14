function x = stft_iw(Sx, opt)
% ISTFT  Inverse short-time Fourier transform
%
% Very closely based on Steven Schimmel's stft.m and istft.m from
% his SPHSC 503: Speech Signal Processing course at Univ. Washington.

if nargin<2, opt = struct(); end

if ~isfield(opt, 'window'), opt.window = round(size(Sx,2)/16); end
if length(opt.window) == 1, opt.window = hamming(opt.window); end
opt.overlap = length(opt.window)-1;

window = opt.window / norm(opt.window, 2); % Unit norm

Nwin = length(window);
n = size(Sx, 2);

% regenerate the full spectrum 0...2pi (minus zero Hz value)
Sx = [Sx; conj(Sx(floor((Nwin+1)/2):-1:2,:))];

% take the inverse fft over the columns
xbuf = real(ifft(Sx,[],1));

% apply the window to the columns
xbuf = xbuf .* repmat(window(:),1,size(xbuf,2));

% overlap-add the columns
x = unbuffer(xbuf,Nwin,opt.overlap);

%%% subfunction
function y = unbuffer(x,w,o)
% UNBUFFER  undo the effect of 'buffering' by overlap-add (see BUFFER)
%    A = UNBUFFER(B,WINDOWLEN,OVERLAP) returns the signal A that is
%    the unbuffered version of B.

y    = [];
skip = w - o;
N    = ceil(w/skip);
L    = (size(x,2) - 1) * skip + size(x,1);

% zero pad columns to make length nearest integer multiple of skip
if size(x,1)<skip*N, x(skip*N,end) = 0; end;

% selectively reshape columns of input into 1-d signals
for i = 1:N
    t = reshape(x(:,i:N:end),1,[]);
    l = length(t);
    y(i,l+(i-1)*skip) = 0;
    y(i,[1:l]+(i-1)*skip) = t;
end;

% overlap-add
y = sum(y,1);
y = y(1:L);

function [xpad, nup, n1, n2] = padsignal(x, padtype)

[nup, n1, n2] = p2up(length(x));

xl = padarray(x(:), n1, padtype, 'pre');
xr = padarray(x(:), n2, padtype, 'post');

xpad = [xl(1:n1); x(:); xr(end-n2+1:end)];

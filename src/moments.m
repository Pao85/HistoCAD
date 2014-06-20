function thresh = moments (img)
    ihist = hist (img(:), 0:255);
	T = moment_s (ihist);
	thresh = double (T{1}) / (numel (ihist) - 1);
end
function level = moment_s (y)
  n = numel (y) - 1;
  % The threshold is chosen such that partial_sumA(y,t)/partial_sumA(y,n) is closest to x0.
  Avec = zeros (1, n+1);
  for t = 0:n
    Avec(t+1) = partial_sumA (y, t) / partial_sumA (y, n);
  end
  % The following finds x0.
  x2 = (partial_sumB(y,n)*partial_sumC(y,n) - partial_sumA(y,n)*partial_sumD(y,n)) / (partial_sumA(y,n)*partial_sumC(y,n) - partial_sumB(y,n)^2);
  x1 = (partial_sumB(y,n)*partial_sumD(y,n) - partial_sumC(y,n)^2) / (partial_sumA (y,n)*partial_sumC(y,n) - partial_sumB(y,n)^2);
  x0 = .5 - (partial_sumB(y,n)/partial_sumA(y,n) + x2/2) / sqrt (x2^2 - 4*x1);
  % And finally the threshold.
  [~, ind] = min (abs (Avec-x0));
  level{1} = ind-1;
end
function x = partial_sumA (y, j)
  x = sum (y(1:j+1));
end
function x = partial_sumB (y, j)
  ind = 0:j;
  x   = ind*y(1:j+1)';
end
function x = partial_sumC (y, j)
  ind = 0:j;
  x = ind.^2*y(1:j+1)';
end
function x = partial_sumD (y, j)
  ind = 0:j;
  x = ind.^3*y(1:j+1)';
end

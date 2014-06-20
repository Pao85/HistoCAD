%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Written by Ivan Cruze
% Modified by Faraz Oloumi
%%%%%%%%%%%%%%%%%%%%%%%%%%%

function thresh = maxentropy (img)
    ihist = hist (img(:), 0:255);
	T = max_entropy (ihist);
	thresh = double (T{1}) / (numel (ihist) - 1);
end

function T = max_entropy(y)
  n = numel (y) - 1;
  % The threshold is chosen such that the following expression is minimized.
    for j = 0:n
      vec(j+1) = negativeE(y,j)/partial_sumA(y,j) - log10(partial_sumA(y,j)) + ...
          (negativeE(y,n)-negativeE(y,j))/(partial_sumA(y,n)-partial_sumA(y,j)) - log10(partial_sumA(y,n)-partial_sumA(y,j));
    end
   [~,ind] = min(vec);
  T{1} = ind-1;
end

%## Entroy function. Note that the function returns the negative of entropy.
function x = negativeE(y,j)
  %## used by the maxentropy method only
  y = y(1:j+1);
  y = y(y~=0);
  x = sum(y.*log10(y));
end

function x = partial_sumA (y, j)
  x = sum (y(1:j+1));
end

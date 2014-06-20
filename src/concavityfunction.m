function thresh = concavityfunction (img)
  ihist = hist (img(:));%, 0:255);
  T = concavity(ihist);
  %## normalize the threshold value to the [0 1] range
  thresh = double (T{1}) / (numel (ihist) - 1);
		
    end

function T = concavity (h)
  n = numel (h) - 1;
  H = hconvhull(h);
  % Find the local maxima of the difference H-h.
  lmax = flocmax(H-h);
  % Find the histogram balance around each index.
  for k = 0:n
    E(k+1) = hbalance(h,k);
  end
  % The threshold is the local maximum with highest balance.
  E = E.*lmax;
  [dummy ind] = max(E);
  T{1} = ind-1;
end

function x = partial_sumA (y, j)
  x = sum (y(1:j+1));
end

%Find the local maxima of a vector using a three point neighborhood.
function y = flocmax(x)
%y    binary vector with maxima of x marked as ones
  len = length(x);
  y = zeros(1,len);
  for k = 2:len-1
    [dummy,ind] = max(x(k-1:k+1));
    if ind == 2
      y(k) = 1;
    end
  end
end

% Calculate the balance measure of the histogram around a histogram index.
function E = hbalance(y,ind)
  n = length(y)-1;
  E = partial_sumA(y,ind)*(partial_sumA(y,n)-partial_sumA(y,ind));
end

% Find the convex hull of a histogram.
function H = hconvhull(h)
  % In:
  %  h    histogram
  %
  % Out:
  %  H    convex hull of histogram
  len = length(h);
  K(1) = 1;
  k = 1;
  % The vector K gives the locations of the vertices of the convex hull.
  while K(k)~=len
    theta = zeros(1,len-K(k));
    for i = K(k)+1:len
      x = i-K(k);
      y = h(i)-h(K(k));
      theta(i-K(k)) = atan2(y,x);
    end
    maximum = max(theta);
    maxloc = find(theta==maximum);
    k = k+1;
    K(k) = maxloc(end)+K(k-1);
  end
  % Form the convex hull.
  H = zeros(1,len);
  for i = 2:length(K)
    H(K(i-1):K(i)) = h(K(i-1))+(h(K(i))-h(K(i-1)))/(K(i)-K(i-1))*(0:K(i)-K(i-1));
  end
end

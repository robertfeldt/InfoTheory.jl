# Calculate the LX76 complexity as described in:
#  F. Kaspar and H.G. Schuster, "Easily Calculable Measure for the 
#  Complexity of Spatiotemporal Patterns", Physical Review A, vol 36, 
#  num 2, pg 842, 1987.
# This implementation is based on the Matlab code by Stephen Faul:
#  http://www.mathworks.co.uk/matlabcentral/fileexchange/6886-kolmogorov-complexity
#
# This is nice and pure Julia but Zlib.compress is much faster so not much use for this...
function lz76_complexity_kaspar_shuster(s, normalize = true)
  n = length(s)
  c = 1
  l = 1

  i = 0
  k = 1
  k_max = 1
  stop = 0

  while stop==0
    if s[i+k] != s[l+k]
      if k > k_max
        k_max=k
      end
      i=i+1
        
      if i==l
        c=c+1
        l=l+k_max
        if l+1>n
          stop=1
        else
          i=0
          k=1
          k_max=1
        end
      else
        k=1
      end
    else
      k=k+1
      if l+k > n
        c=c+1
        stop=1
      end
    end
  end

  if normalize
    # a la Lempel and Ziv (IEEE trans inf theory it-22, 75 (1976), 
    # h(n)=c(n)/b(n) where c(n) is the kolmogorov complexity
    # and h(n) is a normalised measure of complexity.
    b=n/log2(n)
    return c/b
  else
    return c
  end
end

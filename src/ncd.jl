ncd(x, y, clen = zliblength) = ncd(string(x), string(y), clen)

function ncd(x::ASCIIString, y::ASCIIString, clen = zliblength)
  cxy = clen(x * y)
  cx = clen(x)
  cy = clen(y)
  (cxy - min(cx, cy)) / max(cx, cy)
end

# NCD for lists is here called NCDL. It is an implementation of the "NCD for Multisets"
# as described in the paper:
#  A. Cohen & P. Vitanyi, "", 2012, http://arxiv.org/pdf/1212.5711.pdf
# This is a heuristic to calc the NCDL in O(n^2) operations since the def of NCDL implies
# a O(2^n) algorithm.
function ncdl{T <: Any}(X::Array{T, 1}, clen = zliblength)
  ncdl(map(string, X), clen)
end

function ncdl(Xstrs::Array{ASCIIString, 1}, clen = zliblength, return_indexset = false)
  Gxs = map(clen, Xstrs)
  n = length(Xstrs)

  maxncd1 = -10.0 # Start with value < 0.0 to ensure first one is larger (NCD values are between 0.0 and 1+epsilon).

  # We will deselect one element in each step but start with all selected:
  selected = collect(1:n) .> 0
  selectedindices = Set(collect(1:n))
  numselected = n
  best = largest = 0

  while numselected >= 2

    # Calc max G(X \ {x}) for the still selected ones
    maxGxminus1 = -Inf
    for i in selectedindices
      selected[i] = false
      newGxminus1 = clen(join(Xstrs[selected], ""))
      selected[i] = true
      if newGxminus1 > maxGxminus1
        maxGxminus1 = newGxminus1
        largest = i
      end
    end

    # NCD1 = (G(X) - minimum(G(X))) / maxGxminus1
    ncd1 = (clen(join(Xstrs[selected], "")) - minimum(Gxs[selected])) / maxGxminus1
    #println("$numselected: $ncd1")
    if ncd1 > maxncd1
      maxncd1 = ncd1
      best = copy(selectedindices)
    end
    selected[largest] = false
    selectedindices = setdiff(selectedindices, Set(largest))
    numselected -= 1

  end

  if return_indexset
    return (maxncd1, best)
  else
    return maxncd1
  end
end

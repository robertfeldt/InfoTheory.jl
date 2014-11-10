# For classification of an object x we want to now for which multiset the addition
# of x would increase the NCD1 (left-most part of NCDL) the least. So we need a way to calc
# this delta_diameter(A, x). First lets create a type for NCD multi-sets.
type NCDMultiset{T <: Any}
  clen::Function # Function to calc the compressed length of strings
  Xs::Vector{T}  

  # We save the strings in one consecutive string together with their start indices:
  Xstr::ASCIIString
  Xstrstarts::Vector{Int64}

  # Intermediate values used in calculating NCD1:
  Gxstrs::Vector{Int64} # Length of compressed versions of objects
  minGxstr::Int64       # Min length of compressed versions of objects

  # Pre-calc'ed values:
  Gx::Float64
  ncd1::Float64

  NCDMultiset{T <: Any}(A::Array{T, 1}, clen = zliblength) = begin
    Astrs = map(string, A)
    Astrlengths = map(length, Astrs)
    Gxstrs = map(clen, Astrs)

    nm = new(clen, A, 
      join(Astrs, ""), cumsum(Astrlengths),
      Gxstrs, minimum(Gxstrs), -1.0)
    nm
  end
end

# Cached version of methods
ncd1(nm::NCDMultiset, x) = (nm.ncd1 >= 0.0) ? nm.ncd1 : (nm.ncd1 = calc_ncd1(nm))

# NCD1 = (G(X) - minimum(G(X))) / maxGxminus1
function calc_ncd1(nm::NCDMultiset)
  ncd1value, nm.Gx, gxminu1s = ncd1(nm.Xstr, nm.Xstrstarts, nm.minGxstr, nm.clen)
  nm.maxGxminus1 = maximum(gxminus1s)
  ncd1value
end

function ncd1(Xstr, Xstrstarts, minGxstr, clen = zliblength)
  Gx = clen(Xstr)
  gxminus1s = Gxminus1s(Xstr, Xstrstarts, clen)
  maxGxminus1 = maximum(gxminus1s)
  ncd1value = (Gx - minGxstr) / maxGxminus1
  return (ncd1value, Gx, gxminus1s)
end

# Calculate G(X \ {x}) for each x in X.
function Gxminus1s(Xstr, Xstrstarts, clen = zliblength)
  n = length(Xstrstarts)
  result = zeros(n)
  result[1] = clen(Xstr[Xstrstarts[2]:end])
  result[n] = clen(Xstr[1:(Xstrstarts[n]-1)])
  map(2:(n-1)) do i
    Xminus1str = Xstr[1:(Xstrstarts[i]-1)] * Xstr[Xstrstarts[i+1]:end]
    result[i] = clen(Xminus1str)
  end
  result
end

function delta_diameter{T <: Any}(A::Array{T, 1}, x::T, clen = zliblength)
  ncdmultiset = NCDMultiset(A, clen)
  delta_diameter(ncdmultiset, x)
end

# The delta_diameter is NCD1(A + [x]) - NCD1(A)
function delta_diameter(nm::NCDMultiset, x)
  ncd1_a = ncd1(nm) # To calc intermediate arrays that we can then reuse.
  xstr = string(x)
  # Extend string with xstr and recalc ncd1
  Axstr = nm.Xstr * xstr
  starts = copy(nm.Xstrstarts)
  push!(starts, length(nm.Xstr))
  AxGxminus1 = Gxminus1s(Axstr, starts, nm.clen)
  ncd1_ax = (nm.clen(Axstr) - min(nm.minGXstr, length(nm.clen(xstr)))) / maximum(AxGxminus1)
  ncd1_ax - ncd1_a
end

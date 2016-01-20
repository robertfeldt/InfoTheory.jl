# Add functions for calculating the normalized compression distance (NCD).

# Compressors typically write a header to the compressed strings. In NCD calculations
# we do not want to include the length of this header. For each compressor type
# we try to find the length of the header by compressing some very short strings.
# We cache these min lengths in a hash for speedy access later.
const CompressorHeaderLengths = Dict{Any,Int}()

function header_length{C <: Compressor}(compressor::C)
	ct = typeof(compressor)
	if !haskey(CompressorHeaderLengths, ct)
		CompressorHeaderLengths[ct] = find_min_header_length(compressor)
	end
	return CompressorHeaderLengths[ct]
end

const ShortStrings = ["", "a", "b", "z", "A", "B", "Z", "0", "aa", "bb", "zz", "aaa", "zzz"]

function find_min_header_length{C <: Compressor}(compressor::C)
	lens = Int[]
	map(ShortStrings) do s
	  try
	  	push!(lens, clen(compressor, s))
	  catch ex
	  end
	end
	minimum(lens)
end

function ncdcalc(cx::Int, cy::Int, cxy::Int)
	(cxy - min(cx, cy)) / max(cx, cy)
end

function ncd{S <: AbstractString}(c::Compressor, x::S, y::S)
	hlen = header_length(c)
	cx = clen(c, x) - hlen
	cy = clen(c, y) - hlen
	cxy = clen(c, x, y) - hlen
	ncdcalc(cx, cy, cxy)
end

const DefaultCompressor = LibzCompressor()

ncd{S <: AbstractString}(x::S, y::S, c::Compressor = DefaultCompressor) = ncd(c, x, y)
ncd{S1 <: AbstractString, S2 <: Any}(x::S1, y::S2, c::Compressor = DefaultCompressor) = ncd(c, x, string(y))
ncd{S1 <: Any, S2 <: AbstractString}(x::S1, y::S2, c::Compressor = DefaultCompressor) = ncd(c, string(x), y)
ncd{S1 <: Any, S2 <: Any}(x::S1, y::S2, c::Compressor = DefaultCompressor) = ncd(c, string(x), string(y))


# NCD for lists is here called NCDL. It is an implementation of the "NCD for Multisets"
# as described in the paper:
#  A. Cohen & P. Vitanyi, "", 2012, http://arxiv.org/pdf/1212.5711.pdf
# This is a heuristic to calc the NCDL in O(n^2) operations since the def of NCDL implies
# a O(2^n) algorithm.
function ncdl{T <: Any}(Xs::Vector{T}, c::Compressor = LibzCompressor())
  ncdl(map(string, Xs), c)
end

function ncdl{S <: AbstractString}(Xstrs::Vector{S}, c::Compressor = LibzCompressor(), return_indexset = false)
  Gxs = map(x -> clen(c, x), Xstrs)
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
      newGxminus1 = clen(c, join(Xstrs[selected], ""))
      selected[i] = true
      if newGxminus1 > maxGxminus1
        maxGxminus1 = newGxminus1
        largest = i
      end
    end

    # NCD1 = (G(X) - minimum(G(X))) / maxGxminus1
    ncd1 = (clen(c, join(Xstrs[selected], "")) - minimum(Gxs[selected])) / maxGxminus1
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

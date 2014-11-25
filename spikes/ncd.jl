using Zlib
zliblength(str) = length(Zlib.compress(str,9,false,true))

isinstalled(pkg) = try
    isa(Pkg.installed(pkg), VersionNumber)
  catch
    return false
end

# If Blosc is installed we can also use it for compression.
# If you expect strings involved in NCD calculations to be long
# you should definetely use qlz4length, lz4length or lz4hclength
# instead of zliblength as compressiors since they are typically
# an order of magnitude faster.
if isinstalled("Blosc")
  using Blosc
  blosc_compress(s, level = 9, shuffle = false, compressor = "blosclz") = begin
    Blosc.set_compressor(compressor)
    compress(s; level = level, shuffle = shuffle)
  end
  blosclzlength(s) = length(blosc_compress(s, 9, false, "blosclz"))
  lz4length(s) = length(blosc_compress(s, 9, false, "lz4"))
  lz4hclength(s) = length(blosc_compress(s, 9, false, "lz4hc"))
  snappylength(s) = length(blosc_compress(s, 9, false, "snappy"))
  blosczliblength(s) = length(blosc_compress(s, 9, false, "zlib"))

  qlz4length(s) = length(blosc_compress(s, 1, false, "lz4"))
  qsnappylength(s) = length(blosc_compress(s, 1, false, "snappy"))
  qblosczliblength(s) = length(blosc_compress(s, 1, false, "zlib"))
end

# If we are using GZip we need to save to file:
#using GZip
#
#function gzip_length(str) # We should not have to write to disk but couldn't find a way to do it in mem with GZip.jl. Investigate alternatives!
#  fn = tempfilename()
#  gfh = GZip.open(fn, "w")
#  println(gfh, str)
#  close(gfh)
#  len = filesize(fn)
#  rm(fn)
#  len
#end
#function tempfilename()
#  "tempfile_" * strftime("%Y%m%d_%H%M%S_", time()) * string(rand(1:1000000000)) * ".tmp"
#end

ncd(x, y, clen = lz4length) = ncd(string(x), string(y), clen)

function ncd(x::ASCIIString, y::ASCIIString, clen = lz4length)
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
function ncdl{T <: Any}(X::Array{T, 1}, clen = lz4length)
  ncdl(map(string, X), clen)
end

function ncdl(Xstrs::Array{ASCIIString, 1}, clen = lz4length, return_indexset = false)
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

# We can then define the Test Set Diameter (TSD) as the NCDL of the test inputs or the test cases or the traces when executing these tests.
# From TSD we can then define the Test Strategy Diameter for size N, TSD(N), as the average
# TSD for a test set of size generated with that strategy. Strategy here is taken in its most
# general sense, i.e. can be a manual strategy for how to design tests (executed independently many times by different testers)
# or it can be any automated test generation strategy. Since the TSD(N) is a stochastic variable
# we should also use the standard deviation to characterize it. We can also compare different
# strategies (generators) by applying them multiple times and consider which one has the largest
# diameter. We hypothesise that if no further information about the SUT is known a strategy S1
# with a statistically significantly higher TSD(N) than another strategy S2 (TSD(N)_S1 >~ TSD(N)_S2)
# (evaluated with something like a Wilcoxon test, for example) is likely to yield higher fault 
# finding ability.

ncdl([1,2,3,4,5])

# We expect a random uniform sampling to give a larger ncd than a normal sampled one if the latter
# is confined to smaller range.
N = 200
ncdl(int(100.0 * rand(N)))
ncdl(int(50 + 5*randn(N)))

# We expect a generator of arrays of integers that can generate longer arrays to have larger NCDL
# than one which generates shorter arrays.
genintarrays(maxsize, minInt = -100, maxInt = 100) = map((i) -> rand(minInt:maxInt), 1:rand(0:maxsize))
ncdl(map((i) -> genintarrays(3), 1:N))
ncdl(map((i) -> genintarrays(8), 1:N))

# We expect generators generating arrays of same length to have larger ncd if they sample a 
# larger span of the ints:
ncdl(map((i) -> genintarrays(5, -5, 5), 1:N))
ncdl(map((i) -> genintarrays(5, -50, 50), 1:N))
ncdl(map((i) -> genintarrays(5, -5000, 5000), 1:N))

# Calculations are quite slow though:
input = map((i) -> genintarrays(5, -5000, 5000), 1:N);
@time ncdl(input, zliblength)
@time ncdl(input, lz4length)
@time ncdl(input, lz4hclength)
@time ncdl(input, qlz4length)
@time ncdl(input, blosclzlength)

# although I imagine there are many ways we can speed this up if it is really useful.
# A problem with these types of InfoTheory results though is that it is less clear how one
# can incorporate biases in which test sets one prefer. But maybe we solve that with other
# aspects of our tools.

# Benchmark two generators and count the number of times that the first give higher
# NCD than the second one. The generators generate one instance only, they will be called
# repeatedly to create the multisets used for comparison.
function ncd_compare_generators(gen1, gen2;
  lengths = [2, 5, 10, 20, 50, 100],
  reps = 30,
  clen = lz4length)

  counts_higher_ncd = map(lengths) do len
  println("Length = $len")
    count = 0
    for r in 1:reps
      list1 = map((i) -> gen1(), 1:len)
      list2 = map((i) -> gen2(), 1:len)
      ncd1 = ncdl(list1, clen)
      ncd2 = ncdl(list2, clen)
      count += (ncd1 > ncd2 ? 1 : 0)
    end
    count
  end

  100.0 * counts_higher_ncd / reps
end

ncd_compare_generators(() -> genintarrays(8), () -> genintarrays(6))
ncd_compare_generators(() -> genintarrays(5, -50, 50), () -> genintarrays(5, -5, 5); clen = lz4length)

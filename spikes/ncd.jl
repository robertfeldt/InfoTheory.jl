using Zlib

zliblength(str) = length(compress(str,9,false,true))

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
# than one which generates smaller ints.
genintarrays(maxsize, minInt = -100, maxInt = 100) = map((i) -> rand(minInt:maxInt), 1:rand(0:maxsize))
ncdl(map((i) -> genintarrays(3), 1:N))
ncdl(map((i) -> genintarrays(8), 1:N))

# We expect generators generating arrays of same length to have larger ncd if they sample a 
# larger span of the ints:
ncdl(map((i) -> genintarrays(5, -5, 5), 1:N))
ncdl(map((i) -> genintarrays(5, -50, 50), 1:N))
ncdl(map((i) -> genintarrays(5, -5000, 5000), 1:N))

# Calculations are quite slow though:
@time ncdl(map((i) -> genintarrays(5, -5000, 5000), 1:N))
# although I imagine there are many ways we can speed this up if it is really useful.
# A problem with these types of InfoTheory results though is that it is less clear how one
# can incorporate biases in which test sets one prefer. But maybe we solve that with other
# aspects of our tools.
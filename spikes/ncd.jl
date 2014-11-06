using GZip

function tempfilename()
  "tempfile_" * strftime("%Y%m%d_%H%M%S_", time()) * string(rand(1:1000000000)) * ".tmp"
end

function gzip_length(str) # We should not have to write to disk but couldn't find a way to do it in mem with GZip.jl. Investigate alternatives!
  fn = tempfilename()
  gfh = GZip.open(fn, "w")
  println(gfh, str)
  close(gfh)
  len = filesize(fn)
  rm(fn)
  len
end

function ncd(x, y, c = gzip_length)
  xs = string(x)
  ys = string(y)

  cxy = c(xs * ys)
  cx = c(xs)
  cy = c(ys)

  min_xy, max_xy = extrema([cx, cy])

  (cxy - min_xy) / max_xy
end

# NCD for lists is here called NCDL
function ncdl(X::Array{Any}, c = gzip_length)
  Xstrs = map(string, X)
  Xs = string(X)

  Gx = c(Xs)
  Gxs = map(c, X)
  EGmax = Gx - minimum(Gxs)

  # Calculate the max Gx for each set minus one of the original elements
  maxGxminus1 = -Inf
  n = length(X)
  for i in 1:n
    Xminusi = X[[collect(1:(i-1)), collect((i+1):n)]]
    maxGxminus1 = max(maxGxminus1, c(string(Xminusi)))
  end

  # First term:
  NCD1 = EGmax / maxGcminus1

  # Second term is the max nlcd for any subset of X:
  NCD2 = maximum(ncdl_proper_subsets(X)) # This will scale exponentially in the num of terms though...

  # Now the ncdl is just the max of the 1st and 2nd terms:
  max(NCD1, NCD2)
end

# Implement the heuristic approximation of NCDL in the Cohen&Vitanyi 2012 paper instead.

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
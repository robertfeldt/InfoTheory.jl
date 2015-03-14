using InfoTheory

N = 100

# We expect a random uniform sampling to give a larger ncd than a normal sampled one if the latter
# is confined to smaller range.
ncdm(int(100.0 * rand(N)))
ncdm(int(50 + 5*randn(N)))

# We expect a generator of arrays of integers that can generate longer arrays to have larger NCDL
# than one which generates shorter arrays.
genintarrays(maxsize, minInt = -100, maxInt = 100) = map((i) -> rand(minInt:maxInt), 1:rand(0:maxsize))
a8 = map((i) -> genintarrays(8), 1:N)
a3 = map((i) -> genintarrays(3), 1:N)
ncdm(a8)
ncdm(a3)

ncd1plot(a8; plotname = "NCD1 sequence for $N random int arrays of max length 8")
ncd1plot(a3; plotname = "NCD1 sequence for $N random int arrays of max length 3")

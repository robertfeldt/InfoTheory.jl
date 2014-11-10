using Zlib
zliblength(str) = length(Zlib.compress(str,9,false,true))

# If Blosc is installed we can also use it for compression.
# If you expect strings involved in NCD calculations to be long
# you should definetely use qlz4length, lz4length or lz4hclength
# instead of zliblength as compressiors since they are typically
# an order of magnitude faster.
#
# To compile Blosc I had to 
#   1. brew install hdf5
#   2. Pkg.clone("https://github.com/jakebolewski/Blosc.jl.git")
#   3. cp ~/.julia/v0.3/Blosc/deps/build.jl ~/.julia/v0.3/Blosc/deps/deps.jl
#   4. "using Blosc" at a Julia prompt
#
# See also: https://github.com/jakebolewski/Blosc.jl/issues/1
#
if isinstalled("Blosc")
  using Blosc
  lz4hclength(s) = length(Blosc.compress(convert(Vector{Uint8}, s), clevel=9, cname=:lz4hc))
  lz4length(s) = length(Blosc.compress(convert(Vector{Uint8}, s), clevel=9, cname=:lz4))
  qlz4length(s) = length(Blosc.compress(convert(Vector{Uint8}, s), clevel=1, cname=:lz4))
  blosczliblength(s) = length(Blosc.compress(convert(Vector{Uint8}, s), clevel=9, cname=:zlib))
end

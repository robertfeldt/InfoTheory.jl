using Zlib
zliblength(str) = length(Zlib.compress(str,9,false,true))
using Blosc
blosclzlength(s) = length(Blosc.compress(convert(Vector{Uint8}, s), clevel=9, cname=:blosclz))
lz4length(s) = length(Blosc.compress(convert(Vector{Uint8}, s), clevel=9, cname=:lz4))
lz4hclength(s) = length(Blosc.compress(convert(Vector{Uint8}, s), clevel=9, cname=:lz4hc))
bzliblength(s) = length(Blosc.compress(convert(Vector{Uint8}, s), clevel=9, cname=:zlib))

function report(name, func, input)
  tic()
  len = func(input)
  t = toq()
  @printf("%s, time = %.3e seconds, compression ratio = %.3f\n", name, t, length(input)/len)
end

for exponent in 1:7
  n = 10^exponent
  input = Uint8[1:n];
  println("\nInput of length 10^$exponent")
  report("zlib         ", (input) -> zliblength(input), input)
  report("zlib in blosc", (input) -> lz4hclength(input), input)
  report("lz4hc        ", (input) -> bzliblength(input), input)
  report("lz4          ", (input) -> lz4length(input), input)
  report("blosclz      ", (input) -> blosclzlength(input), input)
end
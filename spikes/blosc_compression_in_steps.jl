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

function find_min_len_for_compression(compressLenFunc, seedStr = "a", maxReps = 1000)
  prevclen = currclen = compressLenFunc(seedStr)
  for i in 1:maxReps
    prevclen = currclen
    str = seedStr ^ i
    currclen = compressLenFunc(str)
    #print("(", length(str), ", ", currclen, "), ")
    if currclen < prevclen
      return i, length(str), currclen, length(str)+length(seedStr), compressLenFunc(seedStr^(i+1))
    end
  end
  return -1, str
end

find_min_len_for_compression(blosclzlength, "arne")
find_min_len_for_compression(lz4length, "arne")
find_min_len_for_compression(lz4hclength, "arne")

# Seems that there is a min length around 128 bytes. Below that no compression happens.


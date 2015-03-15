using Zlib

abstract Compressor

minlen(c::Compressor) = c.minlen
clen(c::Compressor, str) = length(compress(c, str))

type ZlibCompressor <: Compressor
  minlen::Int
  level::Int
  # No compression if less than 5 chars.
  ZlibCompressor(; minlen = 5, level = 9) = new(minlen, level)
end

compress(zc::ZlibCompressor, str) = Zlib.compress(str, zc.level, false, true)

# Convenience function for finding the minlen for a compressor
function find_min_len_for_compression(compressor, seedStr = "a", maxReps = 1000)
  prevclen = currclen = clen(compressor, seedStr)
  for i in 1:maxReps
    prevclen = currclen
    str = seedStr ^ i
    currclen = clen(compressor, str)
    if currclen < prevclen
      return i, length(str), currclen, length(str)-length(seedStr), clen(compressor, seedStr^(i-1))
    end
  end
  return -1, str
end


###############################################################################
# Only load Blosc-related functions if the Blosc.jl package is installed
###############################################################################
if isinstalled("Blosc")

using Blosc
blosc_compress(s, level = 9, shuffle = false, compressor = "blosclz") = begin
  Blosc.set_compressor(compressor)
  Blosc.compress(s; level = level, shuffle = shuffle)
end

type BloscCompressor <: Compressor
  minlen::Int
  level::Int
  compressorName
  # Limit for Blosc compression to start seems to be 128 chars.
  BloscCompressor(name; minlen = 128, level = 9) = new(minlen, level, name)
end

# Compressed length of a string.
compress(c::BloscCompressor, str) = blosc_compress(str, c.level, false, c.compressorName)

# Define specific compressors which can be used directly
ZlibC = ZlibCompressor()
BloscLz = BloscCompressor("blosclz")
Lz4 = BloscCompressor("lz4")
Lz4hc = BloscCompressor("lz4hc")
Snappy = BloscCompressor("snappy")
BloscZlib = BloscCompressor("zlib")

QLz4hc = BloscCompressor("lz4hc"; level = 1)

end # end if isinstalled("Blosc")

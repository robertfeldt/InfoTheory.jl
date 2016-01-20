using Zlib
using Libz

abstract Compressor

# Min length of input str for compression to happen
minlen(c::Compressor) = c.minlen

compress{S <: AbstractString}(c::Compressor, str::S) = throw("Missing compress function")

clen{S <: AbstractString}(c::Compressor, str::S) = length(compress(c, str))
clen{S <: AbstractString}(c::Compressor, strs::Vector{S}) = clen(c, join(strs))
clen{S <: AbstractString}(c::Compressor, x::S, y::S) = clen(c, x * y)

type ZlibCompressor <: Compressor
  minlen::Int
  level::Int
  # No compression if less than 5 chars.
  ZlibCompressor(; level = 9) = new(5, level)
end

compress{S <: AbstractString}(zc::ZlibCompressor, str::S) = Zlib.compress(str, zc.level, false, true)

# Some compressors have streaming API's and then we can use that to speed things
# up
abstract StreamCompressor <: Compressor

# Create and return one IO stream for output and one compression stream (for adding input).
# Note that the IO stream is for internal use only so can be reused between multiple calls.
newstreams(sc::StreamCompressor) = raise("Subtypes have not defined a newstreams function")
addtostream(cs, str) = raise("Subtypes have not defined a addtostream function")

function compress{S <: AbstractString}(sc::StreamCompressor, str::S)
	ios, cs = newstreams(sc)
	addtostream(cs, str)
	close(cs)
	takebuf_string(ios)
end

function clen{S <: AbstractString}(sc::StreamCompressor, str::S)
	ios, cs = newstreams(sc)
	addtostream(cs, str)
	close(cs)
	position(ios)
end

function clen{S <: AbstractString}(sc::StreamCompressor, x::S, y::S)
	ios, cs = newstreams(sc)
	addtostream(cs, x)
	addtostream(cs, y)
	close(cs)
	position(ios)
end

function clen{S <: AbstractString}(sc::StreamCompressor, strs::Vector{S})
	ios, cs = newstreams(sc)
	for str in strs
		addtostream(cs, str)
	end
	close(cs)
	position(ios)
end


# Libz is a faster (than Zlib) julia wrapper of Zlib
type LibzCompressor <: StreamCompressor
  minlen::Int
  level::Int
  iobf::IOBuffer
  LibzCompressor(; level = 9) = new(0, level, IOBuffer())
end

function newstreams(lzc::LibzCompressor)
	# Reset the io buffer to its first position
	seek(lzc.iobf, 0)
	zs = ZlibDeflateOutputStream(lzc.iobf; level = lzc.level, gzip = false) # Don't write gzip header
	return lzc.iobf, zs
end

addtostream{S <: AbstractString}(cs, str::S) = write(cs, str)


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
if false # isinstalled("Blosc") # exclude Blosc for now since it is not currently used because of its long min length before it compresses

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

compress{S <: AbstractString}(bc::BloscCompressor, str::S) = blosc_compress(str, bc.level, 
	false, bc.compressorName)

compress_str(c::BloscCompressor, str) = blosc_compress(str, c.level, false, c.compressorName)

# Define specific compressors which can be used directly
ZlibC = ZlibCompressor()
BloscLz = BloscCompressor("blosclz")
Lz4 = BloscCompressor("lz4")
Lz4hc = BloscCompressor("lz4hc")
Snappy = BloscCompressor("snappy")
BloscZlib = BloscCompressor("zlib")

QLz4hc = BloscCompressor("lz4hc"; level = 1)
QSnappy = BloscCompressor("snappy"; level = 1)

zliblength(x) = clen(ZlibC, x)

end # end if isinstalled("Blosc")

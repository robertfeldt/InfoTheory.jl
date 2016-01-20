function ncdmatrix{S <: AbstractString}(c::Compressor, strs::Array{S,1})
	n = length(strs)
	m = zeros(Float64, n, n)
	for i in 1:n
		for j in (i+1):n
			m[i,j] = m[j,i] = ncd(c, strs[i], strs[j])
		end
	end
	m
end

function ncdmatrix{T}(c::Compressor, ary::Array{T,1})
	ncdmatrix(c, map(string, ary))
end

ncdmatrix{T}(ary::Array{T,1}, c::Compressor = DefaultCompressor) = ncdmatrix(c, ary)
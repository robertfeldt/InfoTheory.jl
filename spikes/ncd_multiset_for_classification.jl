# Calc max G(X \ {x}) for the still selected ones
function max_GXminus1(Xstrs::Vector{ASCIIString}, selected, selectedindices, compressor::Compressor)
  maxGxminus1 = -Inf
  largest = 0 # dummy value for now
  for i in selectedindices
    selected[i] = false
    newGxminus1 = clen(compressor, join(Xstrs[selected]))
    selected[i] = true
    if newGxminus1 > maxGxminus1
      maxGxminus1 = newGxminus1
      largest = i
    end
  end
  return maxGxminus1, largest
end

# Calculate the sequence of NCD1 values used in the heuristic approximation
# of NCDM. We stop the sequence when there is not enough string length left
# for the compressor to compress anything since we cannot trust results at that
# point.
function ncd1_sequence(Xstrs::Vector{ASCIIString}, compressor::Compressor = ZlibC)
  Gxs = map(x -> clen(compressor, x), Xstrs)
  n = length(Xstrs)

  # Output will be a list of tuples each saving the NCD1 of that step and the index
  # of the element eliminated in that step.
  result = (Float64,Int)[]
  maxncd1 = -Inf # We will also calculate the maximum ncd1 which can be used as approximate NCDM
  maxatindex = -1

  # We will deselect one in each step but start with all selected
  selected = collect(1:n) .> 0
  selectedindices = Set(collect(1:n))
  numselected = n

  # Concatenation of all remaining strings
  remainingXS = join(Xstrs[selected])

  while numselected >= 2 && length(remainingXS) > minlen(compressor)

    # Calc max G(X \ {x}) for the still selected ones
    maxGxminus1, largest = max_GXminus1(Xstrs, selected, selectedindices, compressor)

    # NCD1 = (G(X) - minimum(G(X))) / maxGxminus1
    ncd1 = (clen(compressor, remainingXS) - minimum(Gxs[selected])) / maxGxminus1

    push!(result, (ncd1, largest))

    if ncd1 > maxncd1
      maxncd1 = ncd1
      maxatindex = length(result)
    end

    # Now remove the string that gave max G(X \ {x}) 
    selected[largest] = false
    delete!(selectedindices, largest)
    numselected -= 1
    remainingXS = join(Xstrs[selected])

  end

  return maxncd1, result, maxatindex
end

# We can apply it for any array of objects by just mapping them to strings.
function ncd1_sequence{T <: Any}(X::Array{T, 1}, compressor::Compressor = ZlibC)
  ncd1_sequence(map(string, X), compressor)
end

function ncdm{T <: Any}(X::Array{T, 1}, compressor::Compressor = ZlibC)
  ncd1_sequence(X, compressor)[1]
end

# We can use an NCD1 sequence to sort the objects if we assume they should enter
# in the reverse order to how they were deleted from the sequence. The elements
# that could not be deleted are randomly added at the start of the sequence.
function sortperm_ncd1_order{T <: Any}(X::Array{T, 1}, ncd1seq = false)
  if ncd1seq == false
    maxncd1, ncd1seq, maxatindex = ncd1_sequence(X)
  end
  deletion_order = map(t -> t[2], ncd1seq)
  non_deleted = setdiff(Set(1:length(X)), deletion_order)
  indices = vcat(shuffle(non_deleted), reverse(deletion_order))
end

using Plotly
Plotly.signin("robertfeldt", "903bj0pymv")

# We plot in reverse order and insert zeroes for values were we did not have enough
# information.
function ncd1plot{T <: Any}(X::Array{T, 1}; compressor::Compressor = ZlibC, plotname = "ncd1plot")
  ncdmvalue, seq = ncd1_sequence(X, compressor)
  num_zeros = length(X) - length(seq)
  values = vcat(zeros(Float64, num_zeros), map(t -> t[1], reverse(seq)))
  x = 1:length(values)

  # Now plot it with plotly
  ncd1_sequence_data = [
    "x" => x,
    "y" => values, 
    "type" => "scatter"
  ]
  data = [ncd1_sequence_data]
  response = Plotly.plot(data, ["filename" => plotname, "fileopt" => "overwrite"])
  response["url"]
end
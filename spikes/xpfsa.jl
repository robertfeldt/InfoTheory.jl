type SymbolDistr{SymbolT}
  symbols::Vector{SymbolT}
  probs::Vector{Float64}
end

probability_vector{T <: Number}(numbers::Vector{T}) = numbers ./ sum(numbers)

# Constructor from Dicts
SymbolDistr{ST, PT}(d::Dict{ST, PT}) = begin
  symbols = collect(keys(d))
  probs = convert(Vector{Float64}, [d[s] for s in symbols])
  SymbolDistr{ST}(symbols, probability_vector(probs))
end

# Return the probability of _symbol_ in distribution _d_.
function prob{ST}(d::SymbolDistr{ST}, symbol)
  index = findfirst(d.symbols, symbol)
  (index == 0) ? 0.0 : d.probs[index]
end

# Return the probabilities of _symbols_ in distribution _d_.
probs{ST}(d::SymbolDistr{ST}, symbols) = convert(Vector{Float64}, map((s) -> prob(d, s), symbols))

# Sample a probability vector and return the index to the
# probability that matched. Assumes the vector sums to 1.0.
function sample(probs::Vector{Float64})
  value = rand()
  for i in 1:length(probs)
    if value < probs[i]
      return i
    else
      value -= probs[i]
    end
  end
  throw("Probability vector was not normalized but has sum $(sum(probs))")
end

# Sample a symbol from a distribution.
sample{ST}(d::SymbolDistr{ST}) = d.symbols[sample(d.probs)]

using Distance

# Distance between two symbol distributions.
function distance{ST}(d1::SymbolDistr{ST}, d2::SymbolDistr{ST}, distanceMetric = JSDivergence())
  symbols = union(Set(d1.symbols), Set(d2.symbols))
  evaluate(distanceMetric, probs(d1, symbols), probs(d2, symbols))
end

# Count the number of samples of each type.
function count_samples(samples)
  # Count the number of samples of each kind
  counts = Dict{Any, Int64}()
  for s in samples
    counts[s] = get(counts, s, 0) + 1
  end
  counts
end  

# Create a map for the empirical distribution of samples from a discrete alphabet
function empirical_distribution(samples)
  counts = count_samples(samples)
  # Normalize to frequencies by dividing by the number of samples
  distr = Dict{Any, Float64}()
  for (k, v) in counts
    distr[k] = counts[k] / length(samples)
  end
  distr
end

# A symbol stream represents an actual or a modeled stream of symbols from a
# finite alphabet.
abstract SymbolStream
alphabet(s::SymbolStream) = s.alphabet # Override if not explicitly saved in the stream

# Return the next sample from a stream if there is one or nothing otherwise.
next(s::SymbolStream) = nothing

type WhiteNoiseStream <: SymbolStream
  alphabet
end

sample(wns::WhiteNoiseStream) = wns.alphabet[rand(1:length(wns.alphabet))]

# We can always get a next sample from a WNS.
next(wns::WhiteNoiseStream) = sample(wns)

# We can also create a WhiteNoiseStream from a symbol distribution and from
# another SymbolStream.
WhiteNoiseStream{ST}(sd::SymbolDistr{ST}) = WhiteNoiseStream(sd.symbols)
WhiteNoiseStream(s::SymbolStream) = WhiteNoiseStream(alphabet(s))

# A fixed stream goes through the values in a given sequence and then stops.
type FixedStream <: SymbolStream
  alphabet
  values
  index
  max_index
  FixedStream(values) = new(unique(values), values, 1, length(values))
end

function next(fs::FixedStream)
  if fs.index <= fs.max_index
    fs.index += 1
    fs.values[fs.index-1]
  else
    nothing
  end
end

# An independent stream copy emits only the symbols that match a white noise
# version of a stream.
type IndependentStreamCopy <: SymbolStream
  base::SymbolStream      # The base stream that we are a copy of
  wns::WhiteNoiseStream   # A white noise stream for the same alphabet as the base stream
  IndependentStreamCopy(s::SymbolStream) = new(s, WhiteNoiseStream(s))
end

function next(isc::IndependentStreamCopy)
  next_base_symbol = next(base)
  while next_base_symbol != nothing && next_base_symbol != next(isc.wns)
    next_base_symbol = next(base)
  end
  return next_base_symbol # is either nothing if the base stream is empty or it is a symbol that matched the symbol from the WhiteNoiseStream
end
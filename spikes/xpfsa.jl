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


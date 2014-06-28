type SymbolDistr{SymbolT}
  symbols::Vector{SymbolT}
  probs::Vector{Float64}
end

probability_vector{T <: Number}(numbers::Vector{T}) = numbers ./ sum(numbers)

# Constructor from Dicts
SymbolDistr{ST, PT}(d::Dict{ST, PT}) = begin
  symbols = collect(keys(d))
  probs = zeros(Float64, length(symbols))
  for i in 1:length(symbols)
    probs[i] = convert(Float64, d[symbols[i]])
  end
  probs = probs ./ sum(probs)
  SymbolDistr{ST}(symbols, probability_vector(probs))
end


# Return the probability of _symbol_ in distribution _d_.
function prob{ST}(d::SymbolDistr{ST}, symbol)
  index = findfirst(d.symbols, symbol)
  if index == 0
    return 0.0
  else
    d.probs[index]
  end
end

# Return the probabilities of _symbols_ in distribution _d_.
function probs{ST}(d::SymbolDistr{ST}, symbols)
  ps = zeros(Float64, length(symbols))
  i = 1
  for s in symbols
    ps[i] = prob(d, s)
    i += 1
  end
  ps
end

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
end

# Sample a symbol from a distribution.
function sample{ST}(d::SymbolDistr{ST})
  d.symbols[sample(d.probs)]
end

using Distance

# Distance between two symbol distributions.
function distance{ST}(d1::SymbolDistr{ST}, d2::SymbolDistr{ST}, distanceMetric = JSDivergence())
  symbols = union(Set(d1.symbols), Set(d2.symbols))
  probs1 = probs(d1, symbols)
  probs2 = probs(d2, symbols)
  evaluate(distanceMetric, probs1, probs2)
end
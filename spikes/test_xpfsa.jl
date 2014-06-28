distr = SymbolDistr(Dict{Int64, Float64}({0 => 0.9, 1 => 0.1}))
distr = SymbolDistr({0 => 0.9, 1 => 0.1})

# Check that only valid symbols are created
@repeatedly begin
  s = sample(distr)
  @test in(s, [0, 1])
end

# Create a map for the empirical distribution of samples from a discrete alphabet
function empirical_distribution(samples)

  # Count the number of samples of each kind
  counts = Dict{Any, Int64}()
  for s in samples
    counts[s] = get(counts, s, 0) + 1
  end

  # Normalize to frequencies by dividing by the number of samples
  distr = Dict{Any, Float64}()
  for (k, v) in counts
    distr[k] = counts[k] / length(samples)
  end

  distr
end

# Get the synchronized probability vectors for the union of the alphabets used in two
# distributions.

# Check that we get roughly the same distributions
N = 10000
@repeatedly begin
  samples = [sample(distr) for i in 1:N]
  edistr = SymbolDistr(empirical_distribution(samples))
  d = distance(edistr, distr)
  @test abs(distance(edistr, distr)) < 1e-3
end

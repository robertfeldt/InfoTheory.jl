distr = SymbolDistr(Dict{Int64, Float64}({0 => 0.9, 1 => 0.1}))
distr = SymbolDistr({0 => 0.9, 1 => 0.1})

# Check that only valid symbols are created
@repeatedly begin
  s = sample(distr)
  @test in(s, [0, 1])
end

ed1 = empirical_distribution([:a, :b])
@test ed1[:a] == 0.5
@test ed1[:b] == 0.5

ed2 = empirical_distribution([:a, :b, :a, :a])
@test ed2[:a] == 0.75
@test ed2[:b] == 0.25

# Check that we get roughly the same distribution when sampling.
N = 10000
@repeatedly begin
  samples = [sample(distr) for i in 1:N]
  edistr = SymbolDistr(empirical_distribution(samples))
  d = distance(edistr, distr)
  @test abs(distance(edistr, distr)) < 1e-3
end

distr = SymbolDistr(Dict{Int64, Float64}({0 => 0.9, 1 => 0.1}))
distr = SymbolDistr({0 => 0.9, 1 => 0.1})

# Check that only valid symbols are created
@repeatedly begin
  s = sample(distr)
  @test in(s, [0, 1])
end

# Check that an empirical distribution can be created based on samples.
ed1 = empirical_distribution([:a, :b])
@test ed1[:a] == 0.5
@test ed1[:b] == 0.5

ed2 = empirical_distribution([:a, :b, :a, :a])
@test ed2[:a] == 0.75
@test ed2[:b] == 0.25

ed3 = empirical_distribution([1, 0, 1, 1])
@test ed3[1] == 0.75
@test ed3[0] == 0.25

ed4 = empirical_distribution([1, "2", 0, 1, 1, 0, "2", 1, 1, 0])
@test ed4[0] == (3/10)
@test ed4[1] == (5/10)
@test ed4["2"] == (2/10)

# Check that we get roughly the same distribution when sampling.
N = 2000
# Should be within 0.05 in probability...
dm = JSDivergence()
expected_bound = max(evaluate(dm, [0.9, 0.1], [0.85, 0.15]), evaluate(dm, [0.9, 0.1], [0.95, 0.05]))
@repeatedly begin
  samples = [sample(distr) for i in 1:N]
  edistr = SymbolDistr(empirical_distribution(samples))
  @test distance(edistr, distr) < expected_bound
end

# A white noise stream from a binary alphabet.
wn = WhiteNoiseStream([0, 1])
@test typeof(wn) <: SymbolStream

# Sampling from a white noise stream gives an empirical distribution close to
# the uniform one.
expected_bound = evaluate(dm, [0.5, 0.5], [0.45, 0.55])
@repeatedly begin
  samples = [sample(wn) for i in 1:N]
  ps = collect(values(empirical_distribution(samples)))
  @test evaluate(dm, [0.5, 0.5], ps) < expected_bound
end

# A white noise stream from a symbol distribution.
wn2 = WhiteNoiseStream(distr)
@test typeof(wn2) <: SymbolStream

# A white noise stream from another symbol stream.
wn3 = WhiteNoiseStream(wn)
@test typeof(wn3) <: SymbolStream

# A fixed stream returns a fixed sequence of values and then returns nothing.
fs1 = FixedStream([0,0,1])
@test typeof(fs1) <: SymbolStream
@test next(fs1) == 0
@test next(fs1) == 0
@test next(fs1) == 1
@test next(fs1) == nothing
@test next(fs1) == nothing
@test next(fs1) == nothing

# An independent stream copy of a fixed stream can never return a sequence
# which is longer than the stream it is a copy of.
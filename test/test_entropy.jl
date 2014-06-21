@test approxeq( differential_entropy([0.0 1.0 2.0 3.0]), 2.77, 1e-2 )

@test approxeq( differential_entropy([0 1 2 3]), 2.77, 1e-2 )
@test approxeq( differential_entropy([0 1 3 2]), 2.77, 1e-2 )
@test approxeq( differential_entropy([0 2 1 3]), 2.77, 1e-2 )
@test approxeq( differential_entropy([0 2 3 1]), 2.77, 1e-2 )
for samples in permutations([0 1 2 3])
  @test approxeq( differential_entropy(samples'), 2.77, 1e-2 )
end

@test approxeq( differential_entropy([0.0 1.0 2.0 2.0]), 2.23, 1e-2 )

@test approxeq( differential_entropy([0 1 2 2]), 2.23, 1e-2 )
@test approxeq( differential_entropy([0 2 1 2]), 2.23, 1e-2 )
@test approxeq( differential_entropy([0 2 2 1]), 2.23, 1e-2 )
for samples in permutations([0 1 2 2])
  @test approxeq( differential_entropy(samples'), 2.23, 1e-2 )
end

@test approxeq( differential_entropy([0 1 1 2]), 1.98, 1e-2 )
for samples in permutations([0 1 1 2])
  @test approxeq( differential_entropy(samples'), 1.98, 1e-2 )
end

# Actual entropy is 0.25*log(0.25) + 0.75*log(0.75)
@test approxeq( differential_entropy([0 1 1 1]), 1.48, 1e-2 )
@test approxeq( differential_entropy([1 2 2 2]), 1.48, 1e-2 )
@test approxeq( differential_entropy([2 3 3 3]), 1.48, 1e-2 )
for samples in permutations([0 1 1 1])
  @test approxeq( differential_entropy(samples'), 1.48, 1e-2 )
end

@test approxeq( differential_entropy([0 1 0 1]), 1.48, 1e-2 )
@test approxeq( differential_entropy([1 0 0 1]), 1.48, 1e-2 )
for samples in permutations([0 0 1 1])
  @test approxeq( differential_entropy(samples'), 1.48, 1e-2 )
end

# Uniform distribution of width alpha should have entropy of log_2(alpha)
@repeatedly begin
  N = 1000
  alpha = 10.0 * rand()
  samples_from_uniform_distr = alpha * rand(1, N)
  expected = log(2, alpha)

  for k in 3:6
    ent = differential_entropy(samples_from_uniform_distr, k)
    #println("estimated = $ent, expected = $expected")
    @test approxeq( ent, expected, 0.15 )
  end
end

#
# Compare to analytically calculated entropies for known distributions, as listed on:
#  http://en.wikipedia.org/wiki/Differential_entropy
#
using Distributions
N = 1000

function diff_entropy_approx_eq(distr, expected, N = N)
  samples = rand(distr, N)
  ent = differential_entropy(samples')
  approxeq(ent, expected, 0.10)
end

# Uniform distribution
@repeatedly begin
  a, b = extrema([rand(-100:100), rand(-100:100)])
  @test diff_entropy_approx_eq( Uniform(a, b), log(2, b-a) )
end

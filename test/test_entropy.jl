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

function diff_entropy_approx_eq(distr, expected, delta = 0.10, N = N)
  samples = rand(distr, N)
  ent = differential_entropy(samples')
  approxeq(ent, expected, delta)
end

# Convert from nats to bits
nats_to_bits(natsvalue) = natsvalue / log(2.0)

@repeatedly begin

  # Uniform distribution
  a = rand(-100.0:100.0)
  b = rand((a+0.01):1e-5:(a+100.0))
  expected_entropy = nats_to_bits( log(b-a) )
  @test diff_entropy_approx_eq( Uniform(a, b), expected_entropy, 0.20 )

  # Normal distribution
  mu = rand(-10.0:1e-6:10.0)
  sigma = rand(0.0:1e-2:100.0)
  expected_entropy = nats_to_bits( log(sigma * sqrt(2*pi*e)) )
  @test diff_entropy_approx_eq( Normal(mu, sigma), expected_entropy, 0.20 ) 

  # Exponential distribution
  lambda = rand(0.0:1e-6:10.0)
  scale = 1/lambda
  expected_entropy = nats_to_bits( 1 - log(lambda) )
  @test diff_entropy_approx_eq( Exponential(scale), expected_entropy, 0.20 ) 

  # Rayleigh distribution
  expected_entropy = nats_to_bits( 1 + log(scale / sqrt(2)) + eulergamma / 2 )
  @test diff_entropy_approx_eq( Rayleigh(scale), expected_entropy, 0.20 ) 

end

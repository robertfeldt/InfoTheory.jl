approxeq(x, y, delta = 1e-5) = abs(x-y) < delta

# Uniform distribution of width alpha should have entropy of log_2(alpha)
@repeatedly begin
	N = 1000
	alpha = 2.0
	samples_from_uniform_distr = alpha * rand(1, N)
	expected = log(2, alpha)

	for k in 3:6
		ent = entropy(samples_from_uniform_distr, k)
		#println("estimated = $ent, expected = $expected")
	  @test approxeq( ent, expected, 1e-1 )
	end
end
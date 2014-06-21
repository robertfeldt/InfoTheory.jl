# Classic Kozachenko-Leonenko k-nearest neighbor differential entropy estimator from
# samples from a continuous random variable. X should be a d*N dimensional 
# matrix where each column is a d-dimensional sample from the distribution.
#
# Example: X = [1.3 3.7 5.1 2.4] if the distribution is 1-dimensional and
# we have 4 samples.
#
# Differential entropy (also referred to as continuous entropy) is a concept in 
# information theory that extends the idea of (Shannon) entropy, a measure of 
# average surprisal of a random variable, to continuous probability distributions.
# For more information see: http://en.wikipedia.org/wiki/Differential_entropy
#
# Note that differential entropy can be negative, unlike discrete entropy.
#
# This is based on the entropy() function in NPEET version 1.1 which, in turn,
# states that it is from Kozachenko and Leonenko as described in the paper:
# A. Kraskov, H. Stogbauer, and P. Grassberger. Estimating mutual information. 
# Phys. Rev. E, 69:066138, Jun 2004.
function differential_entropy{T <: Number}(X::Array{T, 2}, k=3, base=2, knnConstructor = KDTree)

  # Get dimensions
  d, N = size(X)

  # Check that arguments are valid
  if k >= N
    error("k ($k) must be smaller than the number of samples ($N)")
  end

  # Add small noise to break degeneracy. This can happen if samples have limited
  # resolution and just happen to be exactly the same even if the thing measured
  # would not be the same. By adding a very small noise term we avoid any numerical
  # problems because of this.
  xprim = add_noise(X, d, N, 1e-10)

  # Build kNN tree/graph/solution.
  knn_tree = knnConstructor(xprim)

  # Get the k-nearest neighbor distance per point
  knn_dists = zeros(N)
  for i in 1:N
    knn_dists[i] = knn_nearest_distance(xprim, knn_tree, xprim[:,i], k)
  end

  # and estimate the entropy:
  constant = digamma(N) - digamma(k) + d*log(2)
  return( (constant + d * mean(log(knn_dists))) / log(base) )

end

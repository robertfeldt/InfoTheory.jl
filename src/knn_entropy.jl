# Classic Kullback-Liebler k-nearest neighbor entropy estimator from
# samples from a continuous random variable. X should be a d*N dimensional 
# matrix where each column is a d-dimensional sample from the distribution.
#
# Example: X = [1.3 3.7 5.1 2.4] if the distribution is 1-dimensional and
# we have 4 samples.
function entropy(X::Array{Float64, 2}, k=3, base=2, knnConstructor = NaiveNeighborTree)

  # Get dimensions
  d, N = size(X)

  # Check that arguments are valid
  if k >= N
    error("k ($k) must be smaller than the number of samples ($N)")
  end

  # Add small noise to break degeneracy.
  xprim = add_noise(X, d, N, 1e-10)

  # Build kNN tree/graph/solution.
  knn_tree = knnConstructor(xprim)

  # Get the k-nearest neighbor distance per point
  knn_dists = zeros(xprim)
  for i in 1:N
    knn_dists[:,i] = knn_nearest_distance(xprim, knn_tree, xprim[:,i], k)
  end

  # and estimate the entropy:
  constant = digamma(N) - digamma(k) + d*log(2)
  return( (constant + d * mean(log(knn_dists))) / log(base) )

end

add_noise(X, d, N, noiseVar = 1e-10) = X .+ (noiseVar .* rand(d, N))

# Return the kNN nearest point.
function knn_nearest_point(X::Array{Float64, 2}, knnTree, point, k)
  indices, distances = nearest(knnTree, point, k+1)
  sorted = sortperm(distances)
  X[:,indices[sorted[end]]]
end

# Return the kNN nearest point.
function knn_nearest_distance(X::Array{Float64, 2}, knnTree, point, k)
  indices, distances = nearest(knnTree, point, k+1)
  sorted = sortperm(distances)
  distances[sorted[end]]
end
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
module InfoTheory

using NearestNeighbors

export differential_entropy

export IntConfusionMatrix, count

include("knn_entropy.jl")
include("confusion_matrix.jl")

include("utils.jl")

end # module

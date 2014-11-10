module InfoTheory

using Distances
using NearestNeighbors

export differential_entropy
export IntConfusionMatrix, count
export NCDMultiset, ncd1, delta_diameter

include("knn_entropy.jl")
include("confusion_matrix.jl")

include("utils.jl")

# NCD-related functions
include("utils/isinstalled.jl")
include("compress.jl")
include("ncd.jl")
include("ncd_multiset.jl")

end # module

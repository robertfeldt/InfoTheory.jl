module InfoTheory

using Distances
using NearestNeighbors

export differential_entropy
export IntConfusionMatrix, count
#export NCDMultiset, ncd1, delta_diameter
export compress, clen
export ncd
export ncd1_sequence, ncdm, ncd1plot
export ncdmatrix

include("knn_entropy.jl")
include("confusion_matrix.jl")

include("utils.jl")

# NCD-related functions
include("utils/isinstalled.jl")
include("compress.jl")
include("ncd.jl")
include("ncd_matrix.jl")
#include("ncdmultiset.jl")

end # module

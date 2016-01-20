include("helper.jl")
include("minitest.jl")
Minitest.do_tests() do
  #Minitest.include("test_confusion_matrix.jl")
  #Minitest.include("test_entropy.jl")
  Minitest.include("test_compress.jl")
  Minitest.include("test_ncd.jl")
end

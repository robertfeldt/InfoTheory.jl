include("helper.jl")
include("minitest.jl")
Minitest.do_tests() do
  Minitest.include("test_confusion_matrix.jl")
end

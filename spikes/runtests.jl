include("../test/helper.jl")
include("../test/minitest.jl")
Minitest.do_tests() do
  Minitest.include("test_xpfsa.jl")
end

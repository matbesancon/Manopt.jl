using Manopt
using Test
tests = ["testSn","testSPD",
          "testProximalMaps",
          "testGraphConstruction",
          "testGradDesc"]

@testset "Manopt Tests" begin
  for t in tests
    include("$(t).jl")
  end
end

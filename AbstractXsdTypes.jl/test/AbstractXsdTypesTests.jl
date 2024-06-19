module AbstractXsdTypesTests

using ReTest
using AbstractXsdTypes
using Documenter
using ConcreteStructs
using Random

if VERSION < v"1.7"
    const RNG = MersenneTwister(20231002)
else
    const RNG = Xoshiro(20231002)
end

include("type_tests.jl")
include(joinpath("restriction_tests", "restriction_tests.jl"))
include(joinpath("conversion_tests", "conversion_tests.jl"))
include(joinpath("mathematics_functions_tests", "mathematics_functions_tests.jl"))

@testset "doctest" begin
    Documenter.doctest(AbstractXsdTypes)
end

end

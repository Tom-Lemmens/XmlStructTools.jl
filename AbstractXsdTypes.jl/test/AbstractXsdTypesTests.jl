module AbstractXsdTypesTests

using ReTest
using AbstractXsdTypes
using Documenter
using ConcreteStructs
using Random

const RNG = Xoshiro(20231002)

include("type_tests.jl")
include(joinpath("restriction_tests", "restriction_tests.jl"))
include(joinpath("conversion_tests", "conversion_tests.jl"))
include(joinpath("mathematics_functions_tests", "mathematics_functions_tests.jl"))

@testset "doctest" begin
    Documenter.doctest(AbstractXsdTypes)
end

end

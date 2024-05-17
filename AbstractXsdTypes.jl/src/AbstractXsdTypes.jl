module AbstractXsdTypes

using Memoization
using Formatting

include("type_definitions.jl")
include("construction_and_conversion_functions.jl")
include("mathematical_functions.jl")
include(joinpath("restrictions", "value_restrictions.jl"))
include("show_function.jl")

end # module

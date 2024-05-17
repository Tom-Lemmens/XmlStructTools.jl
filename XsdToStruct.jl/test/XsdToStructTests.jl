module XsdToStructTests

using ReTest
using Logging
using XsdToStruct
using TimeZones
using LightXML

# test input data
test_data_dir = pkgdir(XsdToStruct, "test", "test_data")
generic_data_dir = joinpath(test_data_dir, "generic_data")
edge_data_dir = joinpath(test_data_dir, "edge_cases")
specific_data_dir = joinpath(test_data_dir, "specific_cases")
output_dir = pkgdir(XsdToStruct, "test", "test_output")

include("test_utilities.jl")
include("test_xsd_reader.jl")
include("test_xsd_module_generator.jl")
include("test_generated_module.jl")

end

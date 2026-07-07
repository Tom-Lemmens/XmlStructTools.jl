module XmlStructLoaderTests

using ReTest
using Logging
using Dates
using XmlStructLoader
using XsdToStruct

include("test_utilities.jl")
include(joinpath("XmlStructLoaderGenericTests", "XmlStructLoaderGenericTests.jl"))
include("XmlStructLoaderEdgeTests.jl")
include("test_real_world_loading.jl")

end

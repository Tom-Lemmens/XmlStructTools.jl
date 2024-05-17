module XmlStructLoaderTests

using ReTest
using Logging
using XmlStructLoader
using XsdToStruct

include("test_utilities.jl")
include(joinpath("XmlStructLoaderGenericTests", "XmlStructLoaderGenericTests.jl"))
include("XmlStructLoaderEdgeTests.jl")

end

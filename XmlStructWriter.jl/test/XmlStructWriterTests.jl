module XmlStructWriterTests

using ReTest
using Logging
using XmlStructLoader
using XmlStructWriter
using XsdToStruct
import XmlStructPugixml

include("test_utilities.jl")
include("test_xml_writing.jl")

end

"""
    module TestComplexContent

This module was generated with XsdToStruct version 0.1.0 from "complex_content.xsd".
All generated types are exported by this module and some meta data is included in the submodule __meta.

In order to use this module the following dependencies need to be installed:
    AbstractXsdTypes
    Reexport
    Dates
    TimeZones

This module can be used/import as follows:

```julia
include("path/to/complex_content.jl")
using .TestComplexContent
```
or:
```julia
include("path/to/complex_content.jl")
import .TestComplexContent
```
"""
module TestComplexContent

using Reexport

@reexport using AbstractXsdTypes

include("complex_content_struct.jl")
@reexport using .TestComplexContent_struct

module __meta

    import ..TestComplexContent_struct

    root_type = TestComplexContent_struct.documentType
    xsd_filename = "complex_content.xsd"
    XsdToStruct_version = "0.1.0"

end

end

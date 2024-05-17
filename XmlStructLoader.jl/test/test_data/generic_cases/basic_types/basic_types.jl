"""
    module TestComplexAndSimple

This module was generated with XsdToStruct version 0.1.0 from "basic_types.xsd".
All generated types are exported by this module and some meta data is included in the submodule __meta.

In order to use this module the following dependencies need to be installed:
    AbstractXsdTypes
    Reexport
    Dates
    TimeZones

This module can be used/import as follows:

```julia
include("path/to/basic_types.jl")
using .TestComplexAndSimple
```
or:
```julia
include("path/to/basic_types.jl")
import .TestComplexAndSimple
```
"""
module TestComplexAndSimple

using Reexport

@reexport using AbstractXsdTypes

include("basic_types_struct.jl")
@reexport using .TestComplexAndSimple_struct

module __meta

    import ..TestComplexAndSimple_struct

    root_type = TestComplexAndSimple_struct.documentType
    xsd_filename = "basic_types.xsd"
    XsdToStruct_version = "0.1.0"

end

end

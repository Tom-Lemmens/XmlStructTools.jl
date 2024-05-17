"""
    module TestTypeInType

This module was generated with XsdToStruct version 0.1.0 from "type_in_type.xsd".
All generated types are exported by this module and some meta data is included in the submodule __meta.

In order to use this module the following dependencies need to be installed:
    AbstractXsdTypes
    Reexport
    Dates
    TimeZones

This module can be used/import as follows:

```julia
include("path/to/type_in_type.jl")
using .TestTypeInType
```
or:
```julia
include("path/to/type_in_type.jl")
import .TestTypeInType
```
"""
module TestTypeInType

using Reexport

@reexport using AbstractXsdTypes

include("type_in_type_struct.jl")
@reexport using .TestTypeInType_struct

module __meta

    import ..TestTypeInType_struct

    root_type = TestTypeInType_struct.documentType
    xsd_filename = "type_in_type.xsd"
    XsdToStruct_version = "0.1.0"

end

end

"""
    module OptionalElements

This module was generated with XsdToStruct version 0.1.0 from "optional_elements.xsd".
All generated types are exported by this module and some meta data is included in the submodule __meta.

In order to use this module the following dependencies need to be installed:
    AbstractXsdTypes
    Reexport
    Dates
    TimeZones

This module can be used/import as follows:

```julia
include("path/to/optional_elements.jl")
using .OptionalElements
```
or:
```julia
include("path/to/optional_elements.jl")
import .OptionalElements
```
"""
module OptionalElements

using Reexport

@reexport using AbstractXsdTypes

include("optional_elements_struct.jl")
@reexport using .OptionalElements_struct

module __meta

    import ..OptionalElements_struct

    root_type = OptionalElements_struct.documentType
    xsd_filename = "optional_elements.xsd"
    XsdToStruct_version = "0.1.0"

end

end

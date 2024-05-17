"""
    module TestOutOfOrder

This module was generated with XsdToStruct version 0.1.0 from "type_ordering.xsd".
All generated types are exported by this module and some meta data is included in the submodule __meta.

In order to use this module the following dependencies need to be installed:
    AbstractXsdTypes
    Reexport

This module can be used/import as follows:

```julia
include("path/to/type_ordering.jl")
using .TestOutOfOrder
```
or:
```julia
include("path/to/type_ordering.jl")
import .TestOutOfOrder
```
"""
module TestOutOfOrder

using Reexport

@reexport using AbstractXsdTypes

include("type_ordering_struct.jl")
@reexport using .TestOutOfOrder_struct

module __meta

    import ..TestOutOfOrder_struct

    root_type = TestOutOfOrder_struct.documentType
    xsd_filename = "type_ordering.xsd"
    XsdToStruct_version = "0.1.0"

end

end

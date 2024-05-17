"""
    module TestStackedSimple

This module was generated with XsdToStruct version 0.1.0 from "stacked_simple_types.xsd".
All generated types are exported by this module and some meta data is included in the submodule __meta.

In order to use this module the following dependencies need to be installed:
    AbstractXsdTypes
    Reexport

This module can be used/import as follows:

```julia
include("path/to/stacked_simple_types.jl")
using .TestStackedSimple
```
or:
```julia
include("path/to/stacked_simple_types.jl")
import .TestStackedSimple
```
"""
module TestStackedSimple

using Reexport

@reexport using AbstractXsdTypes

include("stacked_simple_types_struct.jl")
@reexport using .TestStackedSimple_struct

module __meta

    import ..TestStackedSimple_struct

    root_type = TestStackedSimple_struct.documentType
    xsd_filename = "stacked_simple_types.xsd"
    XsdToStruct_version = "0.1.0"

end

end

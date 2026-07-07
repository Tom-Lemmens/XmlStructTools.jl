"""
    module LargeSynthetic

This module was generated with XsdToStruct version 0.1.0 from "large_synthetic.xsd".
All generated types are exported by this module and some meta data is included in the submodule __meta.

In order to use this module the following dependencies need to be installed:
    AbstractXsdTypes
    Reexport
    Dates
    TimeZones

This module can be used/import as follows:

```julia
include("path/to/large_synthetic.jl")
using .LargeSynthetic
```
or:
```julia
include("path/to/large_synthetic.jl")
import .LargeSynthetic
```
"""
module LargeSynthetic

using Reexport

@reexport using AbstractXsdTypes

include("large_synthetic_struct.jl")
@reexport using .LargeSynthetic_struct

module __meta

    import ..LargeSynthetic_struct

    root_type = LargeSynthetic_struct.documentType
    xsd_filename = "large_synthetic.xsd"
    XsdToStruct_version = "0.1.0"

end

end

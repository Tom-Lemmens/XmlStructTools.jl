"""
    module TestSimpleTyping

This module was generated with XsdToStruct version 0.1.0 from "simple_types.xsd".
All generated types are exported by this module and some meta data is included in the submodule __meta.

In order to use this module the following dependencies need to be installed:
    AbstractXsdTypes
    Reexport

This module can be used/import as follows:

```julia
include("path/to/simple_types.jl")
using .TestSimpleTyping
```
or:
```julia
include("path/to/simple_types.jl")
import .TestSimpleTyping
```
"""
module TestSimpleTyping

using Reexport

@reexport using AbstractXsdTypes

include("simple_types_struct.jl")
@reexport using .TestSimpleTyping_struct

module __meta

    import ..TestSimpleTyping_struct

    root_type = TestSimpleTyping_struct.documentType
    xsd_filename = "simple_types.xsd"
    XsdToStruct_version = "0.1.0"

end

end

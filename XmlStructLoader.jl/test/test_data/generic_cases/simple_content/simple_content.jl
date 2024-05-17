"""
    module TestSimpleContent

This module was generated with XsdToStruct version 0.1.0 from "simple_content.xsd".
All generated types are exported by this module and some meta data is included in the submodule __meta.

In order to use this module the following dependencies need to be installed:
    AbstractXsdTypes
    Reexport

This module can be used/import as follows:

```julia
include("path/to/simple_content.jl")
using .TestSimpleContent
```
or:
```julia
include("path/to/simple_content.jl")
import .TestSimpleContent
```
"""
module TestSimpleContent

using Reexport

@reexport using AbstractXsdTypes

include("simple_content_struct.jl")
@reexport using .TestSimpleContent_struct

module __meta

    import ..TestSimpleContent_struct

    root_type = TestSimpleContent_struct.documentType
    xsd_filename = "simple_content.xsd"
    XsdToStruct_version = "0.1.0"

end

end

"""
    module TestRootElementInlineType

This module was generated with XsdToStruct version 0.1.0 from "root_element_inline_type.xsd".
All generated types are exported by this module and some meta data is included in the submodule __meta.

In order to use this module the following dependencies need to be installed:
    AbstractXsdTypes
    Reexport

This module can be used/import as follows:

```julia
include("path/to/root_element_inline_type.jl")
using .TestRootElementInlineType
```
or:
```julia
include("path/to/root_element_inline_type.jl")
import .TestRootElementInlineType
```
"""
module TestRootElementInlineType

using Reexport

@reexport using AbstractXsdTypes

include("root_element_inline_type_struct.jl")
@reexport using .TestRootElementInlineType_struct

module __meta

    import ..TestRootElementInlineType_struct

    root_type = TestRootElementInlineType_struct.document
    xsd_filename = "root_element_inline_type.xsd"
    XsdToStruct_version = "0.1.0"

end

end

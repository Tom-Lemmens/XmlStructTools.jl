"""
    module TestTypeInElement

This module was generated with XsdToStruct version 0.1.0 from "type_in_element.xsd".
All generated types are exported by this module and some meta data is included in the submodule __meta.

In order to use this module the following dependencies need to be installed:
    AbstractXsdTypes
    Reexport

This module can be used/import as follows:

```julia
include("path/to/type_in_element.jl")
using .TestTypeInElement
```
or:
```julia
include("path/to/type_in_element.jl")
import .TestTypeInElement
```
"""
module TestTypeInElement

using Reexport

@reexport using AbstractXsdTypes

include("type_in_element_struct.jl")
@reexport using .TestTypeInElement_struct

module __meta

    import ..TestTypeInElement_struct

    root_type = TestTypeInElement_struct.documentType
    xsd_filename = "type_in_element.xsd"
    XsdToStruct_version = "0.1.0"

end

end

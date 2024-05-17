"""
    module TestGroup

This module was generated with XsdToStruct version 0.1.0 from "group_element.xsd".
All generated types are exported by this module and some meta data is included in the submodule __meta.

In order to use this module the following dependencies need to be installed:
    AbstractXsdTypes
    Reexport

This module can be used/import as follows:

```julia
include("path/to/group_element.jl")
using .TestGroup
```
or:
```julia
include("path/to/group_element.jl")
import .TestGroup
```
"""
module TestGroup

using Reexport

@reexport using AbstractXsdTypes

include("group_element_struct.jl")
@reexport using .TestGroup_struct

module __meta

    import ..TestGroup_struct

    root_type = TestGroup_struct.documentType
    xsd_filename = "group_element.xsd"
    XsdToStruct_version = "0.1.0"

end

end

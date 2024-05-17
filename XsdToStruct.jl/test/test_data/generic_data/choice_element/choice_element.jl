"""
    module TestChoice

This module was generated with XsdToStruct version 0.1.0 from "choice_element.xsd".
All generated types are exported by this module and some meta data is included in the submodule __meta.

In order to use this module the following dependencies need to be installed:
    AbstractXsdTypes
    Reexport

This module can be used/import as follows:

```julia
include("path/to/choice_element.jl")
using .TestChoice
```
or:
```julia
include("path/to/choice_element.jl")
import .TestChoice
```
"""
module TestChoice

using Reexport

@reexport using AbstractXsdTypes

include("choice_element_struct.jl")
@reexport using .TestChoice_struct

module __meta

    import ..TestChoice_struct

    root_type = TestChoice_struct.documentType
    xsd_filename = "choice_element.xsd"
    XsdToStruct_version = "0.1.0"

end

end

"""
    module xsd

This module was generated with XsdToStruct version 0.1.0 from "documentation_example.xsd".
All generated types are exported by this module and some meta data is included in the submodule __meta.

In order to use this module the following dependencies need to be installed:
    AbstractXsdTypes
    Reexport

This module can be used/import as follows:

```julia
include("path/to/documentation_example.jl")
using .xsd
```
or:
```julia
include("path/to/documentation_example.jl")
import .xsd
```
"""
module xsd

using Reexport

@reexport using AbstractXsdTypes

include("documentation_example_struct.jl")
@reexport using .xsd_struct

module __meta

    import ..xsd_struct

    root_type = xsd_struct.HouseDescriptionDocumentType
    xsd_filename = "documentation_example.xsd"
    XsdToStruct_version = "0.1.0"

end

end

"""
    module DocumentationExample

This module was generated with XsdToStruct version 0.1.0 from "documentation_example.xsd".
All generated types are exported by this module and some meta data is included in the submodule __meta.

In order to use this module the following dependencies need to be installed:
    AbstractXsdTypes
    Reexport

This module can be used/import as follows:

```julia
include("path/to/documentation_example.jl")
using .DocumentationExample
```
or:
```julia
include("path/to/documentation_example.jl")
import .DocumentationExample
```
"""
module DocumentationExample

using Reexport

@reexport using AbstractXsdTypes

include("documentation_example_struct.jl")
@reexport using .DocumentationExample_struct

module __meta

    import ..DocumentationExample_struct

    root_type = DocumentationExample_struct.HouseDescriptionDocumentType
    xsd_filename = "documentation_example.xsd"
    XsdToStruct_version = "0.1.0"

end

end

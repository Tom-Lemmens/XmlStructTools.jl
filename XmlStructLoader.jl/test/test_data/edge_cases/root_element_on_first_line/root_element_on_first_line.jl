"""
    module TestRootElementFirst

This module was generated with XsdToStruct version 0.1.0 from "root_element_on_first_line.xsd".
All generated types are exported by this module and some meta data is included in the submodule __meta.

In order to use this module the following dependencies need to be installed:
    AbstractXsdTypes
    Reexport
    Dates
    TimeZones

This module can be used/import as follows:

```julia
include("path/to/root_element_on_first_line.jl")
using .TestRootElementFirst
```
or:
```julia
include("path/to/root_element_on_first_line.jl")
import .TestRootElementFirst
```
"""
module TestRootElementFirst

using Reexport

@reexport using AbstractXsdTypes

include("root_element_on_first_line_struct.jl")
@reexport using .TestRootElementFirst_struct

module __meta

    import ..TestRootElementFirst_struct

    root_type = TestRootElementFirst_struct.documentType
    xsd_filename = "root_element_on_first_line.xsd"
    XsdToStruct_version = "0.1.0"

end

end

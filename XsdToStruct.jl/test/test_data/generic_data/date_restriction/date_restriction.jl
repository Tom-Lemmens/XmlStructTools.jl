"""
    module TestDateRestriction

This module was generated with XsdToStruct version 0.1.0 from "date_restriction.xsd".
All generated types are exported by this module and some meta data is included in the submodule __meta.

In order to use this module the following dependencies need to be installed:
    AbstractXsdTypes
    Reexport
    Dates

This module can be used/import as follows:

```julia
include("path/to/date_restriction.jl")
using .TestDateRestriction
```
or:
```julia
include("path/to/date_restriction.jl")
import .TestDateRestriction
```
"""
module TestDateRestriction

using Reexport

@reexport using AbstractXsdTypes

include("date_restriction_struct.jl")
@reexport using .TestDateRestriction_struct

module __meta

    import ..TestDateRestriction_struct

    root_type = TestDateRestriction_struct.documentType
    xsd_filename = "date_restriction.xsd"
    XsdToStruct_version = "0.1.0"

end

end

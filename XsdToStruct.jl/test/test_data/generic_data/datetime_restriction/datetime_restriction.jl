"""
    module TestDateTimeRestriction

This module was generated with XsdToStruct version 0.1.0 from "datetime_restriction.xsd".
All generated types are exported by this module and some meta data is included in the submodule __meta.

In order to use this module the following dependencies need to be installed:
    AbstractXsdTypes
    Reexport
    Dates
    TimeZones

This module can be used/import as follows:

```julia
include("path/to/datetime_restriction.jl")
using .TestDateTimeRestriction
```
or:
```julia
include("path/to/datetime_restriction.jl")
import .TestDateTimeRestriction
```
"""
module TestDateTimeRestriction

using Reexport

@reexport using AbstractXsdTypes

include("datetime_restriction_struct.jl")
@reexport using .TestDateTimeRestriction_struct

module __meta

    import ..TestDateTimeRestriction_struct

    root_type = TestDateTimeRestriction_struct.documentType
    xsd_filename = "datetime_restriction.xsd"
    XsdToStruct_version = "0.1.0"

end

end

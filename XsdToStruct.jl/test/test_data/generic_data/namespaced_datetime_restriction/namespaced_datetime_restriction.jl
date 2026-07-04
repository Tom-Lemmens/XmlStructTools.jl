"""
    module TestNamespacedDateTimeRestriction

This module was generated with XsdToStruct version 0.1.0 from "namespaced_datetime_restriction.xsd".
All generated types are exported by this module and some meta data is included in the submodule __meta.

In order to use this module the following dependencies need to be installed:
    AbstractXsdTypes
    Reexport
    Dates
    TimeZones

This module can be used/import as follows:

```julia
include("path/to/namespaced_datetime_restriction.jl")
using .TestNamespacedDateTimeRestriction
```
or:
```julia
include("path/to/namespaced_datetime_restriction.jl")
import .TestNamespacedDateTimeRestriction
```
"""
module TestNamespacedDateTimeRestriction

using Reexport

@reexport using AbstractXsdTypes

include("namespaced_datetime_restriction_struct.jl")
@reexport using .TestNamespacedDateTimeRestriction_struct

module __meta

    import ..TestNamespacedDateTimeRestriction_struct

    root_type = TestNamespacedDateTimeRestriction_struct.documentType
    xsd_filename = "namespaced_datetime_restriction.xsd"
    XsdToStruct_version = "0.1.0"

end

end

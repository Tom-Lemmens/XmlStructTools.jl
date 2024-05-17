"""
    module TestDateFormats

This module was generated with XsdToStruct version 0.1.0 from "date_formats.xsd".
All generated types are exported by this module and some meta data is included in the submodule __meta.

In order to use this module the following dependencies need to be installed:
    AbstractXsdTypes
    Reexport
    Dates
    TimeZones

This module can be used/import as follows:

```julia
include("path/to/date_formats.jl")
using .TestDateFormats
```
or:
```julia
include("path/to/date_formats.jl")
import .TestDateFormats
```
"""
module TestDateFormats

using Reexport

@reexport using AbstractXsdTypes

include("date_formats_struct.jl")
@reexport using .TestDateFormats_struct

module __meta

    import ..TestDateFormats_struct

    root_type = TestDateFormats_struct.documentType
    xsd_filename = "date_formats.xsd"
    XsdToStruct_version = "0.1.0"

end

end

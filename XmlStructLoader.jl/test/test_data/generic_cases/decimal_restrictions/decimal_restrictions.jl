"""
    module TestDecimalRestrictions

This module was generated with XsdToStruct version 0.1.0 from "decimal_restrictions.xsd".
All generated types are exported by this module and some meta data is included in the submodule __meta.

In order to use this module the following dependencies need to be installed:
    AbstractXsdTypes
    Reexport

This module can be used/import as follows:

```julia
include("path/to/decimal_restrictions.jl")
using .TestDecimalRestrictions
```
or:
```julia
include("path/to/decimal_restrictions.jl")
import .TestDecimalRestrictions
```
"""
module TestDecimalRestrictions

using Reexport

@reexport using AbstractXsdTypes

include("decimal_restrictions_struct.jl")
@reexport using .TestDecimalRestrictions_struct

module __meta

    import ..TestDecimalRestrictions_struct

    root_type = TestDecimalRestrictions_struct.documentType
    xsd_filename = "decimal_restrictions.xsd"
    XsdToStruct_version = "0.1.0"

end

end

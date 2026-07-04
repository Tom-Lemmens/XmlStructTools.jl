module TestDateTimeRestriction_struct

using Reexport
@reexport using Dates
@reexport using TimeZones
import AbstractXsdTypes

"""
An example of a dateTime based simple type without restriction facets.
"""
Base.@kwdef struct TestSimpleType1 <: AbstractXsdTypes.AbstractXSDDateTime
    value::Union{ZonedDateTime, DateTime}
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export TestSimpleType1

Base.@kwdef struct documentType <: AbstractXsdTypes.AbstractXSDComplex
    TestElement1::TestSimpleType1
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export documentType

end

module TestDateFormats_struct

using Reexport
@reexport using Dates
@reexport using TimeZones
import AbstractXsdTypes

"""
An example of a complex xsd type with a vector of date times.
"""
Base.@kwdef struct TestComplexType1 <: AbstractXsdTypes.AbstractXSDComplex
    Element_dateTime::Vector{Union{ZonedDateTime, DateTime}}
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export TestComplexType1

Base.@kwdef struct documentType <: AbstractXsdTypes.AbstractXSDComplex
    TestElement1::TestComplexType1
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export documentType

end

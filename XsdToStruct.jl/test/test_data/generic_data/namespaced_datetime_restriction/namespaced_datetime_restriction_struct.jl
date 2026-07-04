module TestNamespacedDateTimeRestriction_struct

using Reexport
@reexport using Dates
@reexport using TimeZones
import AbstractXsdTypes

"""
A date based simple type with a namespace-prefixed restriction base, as commonly seen in real-world XSDs (e.g. ISO 20022).
"""
Base.@kwdef struct ISODate <: AbstractXsdTypes.AbstractXSDDate
    value::Date
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export ISODate

"""
A dateTime based simple type with a namespace-prefixed restriction base.
"""
Base.@kwdef struct ISODateTime <: AbstractXsdTypes.AbstractXSDDateTime
    value::Union{ZonedDateTime, DateTime}
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export ISODateTime

Base.@kwdef struct documentType <: AbstractXsdTypes.AbstractXSDComplex
    TestElement1::ISODate
    TestElement2::ISODateTime
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export documentType

end

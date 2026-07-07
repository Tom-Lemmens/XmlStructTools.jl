module LargeSynthetic_struct

using Reexport
@reexport using Dates
@reexport using TimeZones
import AbstractXsdTypes

Base.@kwdef struct CurrencyCode <: AbstractXsdTypes.AbstractXSDString
    value::String
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
    function CurrencyCode(
        value::AbstractString,
        __xml_attributes::Union{Nothing, Dict{String, String}}=nothing,
        __validated::Bool=true)
        if __validated
            AbstractXsdTypes.check_restrictions(CurrencyCode, value)
        end
        return new(value, __xml_attributes, __validated)
    end
end

export CurrencyCode

"""
A single repeated record - the element this fixture stresses at scale.
"""
Base.@kwdef struct EntryType <: AbstractXsdTypes.AbstractXSDComplex
    EntryId::String
    Amount::Float64
    Currency::CurrencyCode
    BookingDate::Union{ZonedDateTime, DateTime}
    CreditDebitIndicator::Bool
    Reference::String
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export EntryType

Base.@kwdef struct documentType <: AbstractXsdTypes.AbstractXSDComplex
    Entry::Vector{EntryType}
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export documentType

end

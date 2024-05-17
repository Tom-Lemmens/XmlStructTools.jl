module TestComplexContent_struct

using Reexport
@reexport using Dates
@reexport using TimeZones
import AbstractXsdTypes

Base.@kwdef struct SimpleType1 <: AbstractXsdTypes.AbstractXSDFloat
    value::Float64
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export SimpleType1

module TestComplexType1Types


    import AbstractXsdTypes

    using ..TestComplexContent_struct

    Base.@kwdef struct Element_empty <: AbstractXsdTypes.AbstractXSDComplex
        __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
        __validated::Bool = true
    end

end

export TestComplexType1Types

"""
An example of a complex xsd type.
"""
Base.@kwdef struct TestComplexType1 <: AbstractXsdTypes.AbstractXSDComplex
    Element_string::String
    Element_double::Float64
    Element_boolean::Bool
    Element_decimal::Float64
    Element_dateTime::Union{ZonedDateTime, DateTime}
    Element_integer::Int64
    Element_nonNegativeInteger::UInt64
    Element_positiveInteger::UInt64
    Element_empty::Union{Nothing, TestComplexType1Types.Element_empty} = nothing
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export TestComplexType1

"""
An example of a complex xsd type with complex content.
"""
Base.@kwdef struct TestComplexType2 <: AbstractXsdTypes.AbstractXSDComplex
    Element_string::String
    Element_double::Float64
    Element_boolean::Bool
    Element_decimal::Float64
    Element_dateTime::Union{ZonedDateTime, DateTime}
    Element_integer::Int64
    Element_nonNegativeInteger::UInt64
    Element_positiveInteger::UInt64
    Element_empty::Union{Nothing, TestComplexType1Types.Element_empty} = nothing
    Element_integer_ext::Int64
    Element_boolean_ext::Bool
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export TestComplexType2

"""
An example of a complex xsd type with complex content.
"""
Base.@kwdef struct TestComplexType3 <: AbstractXsdTypes.AbstractXSDComplex
    Element_string::String
    Element_double::Float64
    Element_boolean::Bool
    Element_decimal::Float64
    Element_dateTime::Union{ZonedDateTime, DateTime}
    Element_integer::Int64
    Element_nonNegativeInteger::UInt64
    Element_positiveInteger::UInt64
    Element_empty::Union{Nothing, TestComplexType1Types.Element_empty} = nothing
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export TestComplexType3

module TestComplexType4Types


    import AbstractXsdTypes

    using ..TestComplexContent_struct

    Base.@kwdef struct simple1 <: AbstractXsdTypes.AbstractXSDFloat
        value::SimpleType1
        __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
        __validated::Bool = true
    end

end

export TestComplexType4Types

Base.@kwdef struct TestComplexType4 <: AbstractXsdTypes.AbstractXSDComplex
    simple1::TestComplexType4Types.simple1
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

AbstractXsdTypes.defaults(::Type{TestComplexType4}) = (simple1 = TestComplexType4Types.simple1(0.0), )

export TestComplexType4

Base.@kwdef struct TestComplexType5 <: AbstractXsdTypes.AbstractXSDComplex
    simple1::TestComplexType4Types.simple1
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

AbstractXsdTypes.defaults(::Type{TestComplexType5}) = (simple1 = TestComplexType4Types.simple1(0.0), )

export TestComplexType5

Base.@kwdef struct documentType <: AbstractXsdTypes.AbstractXSDComplex
    TestElement2::TestComplexType2
    TestElement3::TestComplexType3
    TestElement5::TestComplexType5
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export documentType

end

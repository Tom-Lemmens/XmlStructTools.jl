module OptionalElements_struct

using Reexport
@reexport using Dates
@reexport using TimeZones
import AbstractXsdTypes

"""
An example of a simple xsd type.
"""
Base.@kwdef struct TestSimpleType1 <: AbstractXsdTypes.AbstractXSDFloat
    value::Float64
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
    function TestSimpleType1(
        value::Number,
        __xml_attributes::Union{Nothing, Dict{String, String}}=nothing,
        __validated::Bool=true)
        if __validated
            AbstractXsdTypes.check_restrictions(TestSimpleType1, value)
        end
        return new(value, __xml_attributes, __validated)
    end
end

@inline AbstractXsdTypes.get_max_value(::Type{TestSimpleType1})::Float64 = 100.0

@inline AbstractXsdTypes.is_max_exclusive(::Type{TestSimpleType1})::Bool = false

@inline AbstractXsdTypes.get_restriction_checks(::Type{TestSimpleType1}) = (
    AbstractXsdTypes.bound_restriction_check,)

export TestSimpleType1

"""
An example of a simple xsd type.
"""
Base.@kwdef struct TestSimpleType2 <: AbstractXsdTypes.AbstractXSDString
    value::String
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
    function TestSimpleType2(
        value::AbstractString,
        __xml_attributes::Union{Nothing, Dict{String, String}}=nothing,
        __validated::Bool=true)
        if __validated
            AbstractXsdTypes.check_restrictions(TestSimpleType2, value)
        end
        return new(value, __xml_attributes, __validated)
    end
end

export TestSimpleType2

module TestComplexType5Types


    import AbstractXsdTypes

    using ..OptionalElements_struct

    """
    An example of a simple xsd type.
    """
    Base.@kwdef struct Element_simple1 <: AbstractXsdTypes.AbstractXSDString
        value::String
        __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
        __validated::Bool = true
        function Element_simple1(
            value::AbstractString,
            __xml_attributes::Union{Nothing, Dict{String, String}}=nothing,
            __validated::Bool=true)
            if __validated
                AbstractXsdTypes.check_restrictions(Element_simple1, value)
            end
            return new(value, __xml_attributes, __validated)
        end
    end

    """
    An example of a simple xsd type.
    """
    Base.@kwdef struct Element_simple2 <: AbstractXsdTypes.AbstractXSDString
        value::String
        __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
        __validated::Bool = true
        function Element_simple2(
            value::AbstractString,
            __xml_attributes::Union{Nothing, Dict{String, String}}=nothing,
            __validated::Bool=true)
            if __validated
                AbstractXsdTypes.check_restrictions(Element_simple2, value)
            end
            return new(value, __xml_attributes, __validated)
        end
    end

end

export TestComplexType5Types

"""
An example of a complex xsd type with an optional element with a type defined inside.
"""
Base.@kwdef struct TestComplexType5 <: AbstractXsdTypes.AbstractXSDComplex
    Element_simple1::Union{Nothing, TestComplexType5Types.Element_simple1} = nothing
    Element_simple2::Union{Nothing, TestComplexType5Types.Element_simple2} = nothing
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

AbstractXsdTypes.defaults(::Type{TestComplexType5}) = (Element_simple2 = TestComplexType5Types.Element_simple2("file.ext"), )

export TestComplexType5

"""
An example of a complex xsd type with optional dateTime elements.
"""
Base.@kwdef struct TestComplexType6 <: AbstractXsdTypes.AbstractXSDComplex
    Element_simple1::Union{Nothing, Union{ZonedDateTime, DateTime}} = nothing
    Element_simple2::Union{Nothing, Union{ZonedDateTime, DateTime}} = nothing
    Element_simple3::Union{ZonedDateTime, DateTime}
    Element_simple4::Union{Nothing, Union{ZonedDateTime, DateTime}} = nothing
    Element_simple5::Union{Nothing, Union{ZonedDateTime, DateTime}} = nothing
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

AbstractXsdTypes.defaults(::Type{TestComplexType6}) = (Element_simple1 = ZonedDateTime("0001-01-01T00:00:00+00:00", "yyyy-mm-ddTHH:MM:SSzzzzzz"), Element_simple3 = DateTime("0001-02-03T04:05:06.666"), Element_simple4 = ZonedDateTime("0999-08-07T06:55:44-03:22", "yyyy-mm-ddTHH:MM:SSzzzzzz"), Element_simple5 = ZonedDateTime("0004-05-06T07:08:09Z", "yyyy-mm-ddTHH:MM:SSzzzzzz"), )

export TestComplexType6

"""
An example of a complex xsd type with an optional element without default value.
"""
Base.@kwdef struct TestComplexType1 <: AbstractXsdTypes.AbstractXSDComplex
    Element_string::Union{Nothing, String} = nothing
    Element_double::Float64
    Element_simple1::Union{Nothing, TestSimpleType1} = nothing
    Element_simple2::Union{Nothing, TestSimpleType2} = nothing
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export TestComplexType1

"""
An example of a complex xsd type with an optional elements with default values.
"""
Base.@kwdef struct TestComplexType2 <: AbstractXsdTypes.AbstractXSDComplex
    Element_string::String
    Element_double::Float64
    Element_simple1::Union{Nothing, TestSimpleType1} = nothing
    Element_simple2::Union{Nothing, TestSimpleType2} = nothing
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

AbstractXsdTypes.defaults(::Type{TestComplexType2}) = (Element_string = String("aaa"), Element_double = Float64(55.2), Element_simple1 = TestSimpleType1(0), Element_simple2 = TestSimpleType2("AAAA"), )

export TestComplexType2

"""
An example of a complex xsd type with vector optional elements and default values.
"""
Base.@kwdef struct TestComplexType3 <: AbstractXsdTypes.AbstractXSDComplex
    Element_simple1::Union{Nothing, Vector{TestSimpleType1}} = nothing
    Element_simple2::Union{Nothing, Vector{TestSimpleType2}} = nothing
    Element_simple2_or_nothing::Union{Nothing, Vector{TestSimpleType2}} = nothing
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

AbstractXsdTypes.defaults(::Type{TestComplexType3}) = (Element_simple1 = TestSimpleType1(0), Element_simple2 = TestSimpleType2("AAAA"), )

export TestComplexType3

"""
An example of a complex xsd type with optional simple elements.
"""
Base.@kwdef struct TestComplexType4_element <: AbstractXsdTypes.AbstractXSDComplex
    Element_simple1_1::Union{Nothing, TestSimpleType1} = nothing
    Element_simple1_2::Union{Nothing, TestSimpleType1} = nothing
    Element_simple2_1::Union{Nothing, TestSimpleType2} = nothing
    Element_simple2_2::Union{Nothing, TestSimpleType2} = nothing
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

AbstractXsdTypes.defaults(::Type{TestComplexType4_element}) = (Element_simple1_2 = TestSimpleType1(50), Element_simple2_2 = TestSimpleType2("A4A4"), )

export TestComplexType4_element

"""
An example of a complex xsd type with complex optional values.
"""
Base.@kwdef struct TestComplexType4 <: AbstractXsdTypes.AbstractXSDComplex
    Element_complex4::Union{Nothing, Vector{TestComplexType4_element}} = nothing
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export TestComplexType4

Base.@kwdef struct documentType <: AbstractXsdTypes.AbstractXSDComplex
    TestElement1::TestComplexType1
    TestElement2::TestComplexType2
    TestElement3::TestComplexType3
    TestElement4::TestComplexType4
    TestElement5::TestComplexType5
    TestElement6::TestComplexType6
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export documentType

end

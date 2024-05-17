module TestTypeInElement_struct

import AbstractXsdTypes

"""
An example of a simple xsd type.
"""
Base.@kwdef struct TestSimpleType1 <: AbstractXsdTypes.AbstractXSDString
    value::String
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
    function TestSimpleType1(
        value::AbstractString,
        __xml_attributes::Union{Nothing, Dict{String, String}}=nothing,
        __validated::Bool=true)
        if __validated
            AbstractXsdTypes.check_restrictions(TestSimpleType1, value)
        end
        return new(value, __xml_attributes, __validated)
    end
end

export TestSimpleType1

"""
An example of a simple xsd type.
"""
Base.@kwdef struct TestSimpleType2 <: AbstractXsdTypes.AbstractXSDFloat
    value::Float64
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
    function TestSimpleType2(
        value::Number,
        __xml_attributes::Union{Nothing, Dict{String, String}}=nothing,
        __validated::Bool=true)
        if __validated
            AbstractXsdTypes.check_restrictions(TestSimpleType2, value)
        end
        return new(value, __xml_attributes, __validated)
    end
end

@inline AbstractXsdTypes.get_max_fraction_digits(::Type{TestSimpleType2})::Int = 4

@inline AbstractXsdTypes.get_restriction_checks(::Type{TestSimpleType2}) = (
    AbstractXsdTypes.fraction_digits_check,)

export TestSimpleType2

module documentTypeTypes


    import AbstractXsdTypes

    using ..TestTypeInElement_struct

    """
    An example of a simple xsd type.
    """
    Base.@kwdef struct TestSimple2 <: AbstractXsdTypes.AbstractXSDString
        value::String
        __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
        __validated::Bool = true
        function TestSimple2(
            value::AbstractString,
            __xml_attributes::Union{Nothing, Dict{String, String}}=nothing,
            __validated::Bool=true)
            if __validated
                AbstractXsdTypes.check_restrictions(TestSimple2, value)
            end
            return new(value, __xml_attributes, __validated)
        end
    end

    """
    An example of a complex xsd type.
    """
    Base.@kwdef struct TestComplex1 <: AbstractXsdTypes.AbstractXSDComplex
        Element_string::String
        Element_double::Float64
        Element_boolean::Bool
        __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
        __validated::Bool = true
    end

    """
    An example of an extended simple xsd type.
    """
    Base.@kwdef struct TestComplex2 <: AbstractXsdTypes.AbstractXSDString
        value::TestSimpleType1
        __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
        __validated::Bool = true
    end

    """
    An example of an restricted simple xsd type.
    """
    Base.@kwdef struct TestComplex3 <: AbstractXsdTypes.AbstractXSDFloat
        value::TestSimpleType2
        __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
        __validated::Bool = true
        function TestComplex3(
            value::Number,
            __xml_attributes::Union{Nothing, Dict{String, String}}=nothing,
            __validated::Bool=true)
            if __validated
                AbstractXsdTypes.check_restrictions(TestComplex3, value)
            end
            return new(value, __xml_attributes, __validated)
        end
    end

    @inline AbstractXsdTypes.get_min_value(::Type{TestComplex3})::TestSimpleType2 = TestSimpleType2(0.00)

    @inline AbstractXsdTypes.is_min_exclusive(::Type{TestComplex3})::Bool = false

    @inline AbstractXsdTypes.get_restriction_checks(::Type{TestComplex3}) = (
        AbstractXsdTypes.bound_restriction_check,)

end

export documentTypeTypes

Base.@kwdef struct documentType <: AbstractXsdTypes.AbstractXSDComplex
    TestSimple2::documentTypeTypes.TestSimple2
    TestComplex1::documentTypeTypes.TestComplex1
    TestComplex2::documentTypeTypes.TestComplex2
    TestComplex3::documentTypeTypes.TestComplex3
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export documentType

end

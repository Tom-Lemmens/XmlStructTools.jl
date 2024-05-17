module TestSimpleTyping_struct

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
Base.@kwdef struct TestSimpleType2 <: AbstractXsdTypes.AbstractXSDSigned
    value::Int64
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

@inline AbstractXsdTypes.get_max_value(::Type{TestSimpleType2})::Int64 = 500

@inline AbstractXsdTypes.is_max_exclusive(::Type{TestSimpleType2})::Bool = false

@inline AbstractXsdTypes.get_min_value(::Type{TestSimpleType2})::Int64 = 100

@inline AbstractXsdTypes.is_min_exclusive(::Type{TestSimpleType2})::Bool = false

@inline AbstractXsdTypes.get_restriction_checks(::Type{TestSimpleType2}) = (
    AbstractXsdTypes.bound_restriction_check,)

export TestSimpleType2

"""
An example of a simple xsd type.
"""
Base.@kwdef struct TestSimpleType4 <: AbstractXsdTypes.AbstractXSDUnsigned
    value::UInt64
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
    function TestSimpleType4(
        value::Number,
        __xml_attributes::Union{Nothing, Dict{String, String}}=nothing,
        __validated::Bool=true)
        if __validated
            AbstractXsdTypes.check_restrictions(TestSimpleType4, value)
        end
        return new(value, __xml_attributes, __validated)
    end
end

@inline AbstractXsdTypes.get_max_value(::Type{TestSimpleType4})::UInt64 = 50

@inline AbstractXsdTypes.is_max_exclusive(::Type{TestSimpleType4})::Bool = false

@inline AbstractXsdTypes.get_min_value(::Type{TestSimpleType4})::UInt64 = 10

@inline AbstractXsdTypes.is_min_exclusive(::Type{TestSimpleType4})::Bool = false

@inline AbstractXsdTypes.get_restriction_checks(::Type{TestSimpleType4}) = (
    AbstractXsdTypes.bound_restriction_check,)

export TestSimpleType4

"""
An example of a simple xsd type.
"""
Base.@kwdef struct TestSimpleType5 <: AbstractXsdTypes.AbstractXSDFloat
    value::Float64
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
    function TestSimpleType5(
        value::Number,
        __xml_attributes::Union{Nothing, Dict{String, String}}=nothing,
        __validated::Bool=true)
        if __validated
            AbstractXsdTypes.check_restrictions(TestSimpleType5, value)
        end
        return new(value, __xml_attributes, __validated)
    end
end

@inline AbstractXsdTypes.get_max_value(::Type{TestSimpleType5})::Float64 = 200.0

@inline AbstractXsdTypes.is_max_exclusive(::Type{TestSimpleType5})::Bool = false

@inline AbstractXsdTypes.get_min_value(::Type{TestSimpleType5})::Float64 = -200.0

@inline AbstractXsdTypes.is_min_exclusive(::Type{TestSimpleType5})::Bool = false

@inline AbstractXsdTypes.get_restriction_checks(::Type{TestSimpleType5}) = (
    AbstractXsdTypes.bound_restriction_check,)

export TestSimpleType5

Base.@kwdef struct TestComplexType1 <: AbstractXsdTypes.AbstractXSDComplex
    TestElement1::TestSimpleType1
    TestElement2::TestSimpleType2
    TestElement3::Bool
    TestElement4::TestSimpleType4
    TestElement5::TestSimpleType5
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export TestComplexType1

"""
An example of a type with string based elements both with and without default values.
"""
Base.@kwdef struct TestComplexType2 <: AbstractXsdTypes.AbstractXSDComplex
    TestElement11::TestSimpleType1
    TestElement12::TestSimpleType1
    TestElement21::TestSimpleType2
    TestElement22::TestSimpleType2
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

AbstractXsdTypes.defaults(::Type{TestComplexType2}) = (TestElement11 = TestSimpleType1("DEFA"), TestElement21 = TestSimpleType2(100), )

export TestComplexType2

Base.@kwdef struct documentType <: AbstractXsdTypes.AbstractXSDComplex
    TestElement1::TestComplexType1
    TestElement2::TestComplexType2
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export documentType

end

module TestStackedSimple_struct

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
An example of a simple xsd type based on another simple type.
"""
Base.@kwdef struct TestSimpleType2 <: AbstractXsdTypes.AbstractXSDString
    value::TestSimpleType1
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

"""
An example of a simple xsd type.
"""
Base.@kwdef struct TestSimpleType3 <: AbstractXsdTypes.AbstractXSDSigned
    value::Int64
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
    function TestSimpleType3(
        value::Number,
        __xml_attributes::Union{Nothing, Dict{String, String}}=nothing,
        __validated::Bool=true)
        if __validated
            AbstractXsdTypes.check_restrictions(TestSimpleType3, value)
        end
        return new(value, __xml_attributes, __validated)
    end
end

@inline AbstractXsdTypes.get_min_value(::Type{TestSimpleType3})::Int64 = 100

@inline AbstractXsdTypes.is_min_exclusive(::Type{TestSimpleType3})::Bool = false

@inline AbstractXsdTypes.get_restriction_checks(::Type{TestSimpleType3}) = (
    AbstractXsdTypes.bound_restriction_check,)

export TestSimpleType3

"""
An example of a simple xsd type based on another simple type.
"""
Base.@kwdef struct TestSimpleType4 <: AbstractXsdTypes.AbstractXSDSigned
    value::TestSimpleType3
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

@inline AbstractXsdTypes.get_max_value(::Type{TestSimpleType4})::TestSimpleType3 = TestSimpleType3(500)

@inline AbstractXsdTypes.is_max_exclusive(::Type{TestSimpleType4})::Bool = false

@inline AbstractXsdTypes.get_restriction_checks(::Type{TestSimpleType4}) = (
    AbstractXsdTypes.bound_restriction_check,)

export TestSimpleType4

Base.@kwdef struct documentType <: AbstractXsdTypes.AbstractXSDComplex
    TestElement1::TestSimpleType2
    TestElement2::TestSimpleType4
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export documentType

end

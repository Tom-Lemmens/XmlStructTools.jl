module TestDecimalRestrictions_struct

import AbstractXsdTypes

"""
An example of a totalDigits restricted decimal type.
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

@inline AbstractXsdTypes.get_max_total_digits(::Type{TestSimpleType1})::Int = 4

@inline AbstractXsdTypes.get_restriction_checks(::Type{TestSimpleType1}) = (
    AbstractXsdTypes.total_digits_check,)

export TestSimpleType1

"""
An example of a fractionDigits restricted decimal type.
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

@inline AbstractXsdTypes.get_max_fraction_digits(::Type{TestSimpleType2})::Int = 3

@inline AbstractXsdTypes.get_restriction_checks(::Type{TestSimpleType2}) = (
    AbstractXsdTypes.fraction_digits_check,)

export TestSimpleType2

"""
An example of a maxInclusive restricted decimal type.
"""
Base.@kwdef struct TestSimpleType3 <: AbstractXsdTypes.AbstractXSDFloat
    value::Float64
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

@inline AbstractXsdTypes.get_max_value(::Type{TestSimpleType3})::Float64 = 10.1

@inline AbstractXsdTypes.is_max_exclusive(::Type{TestSimpleType3})::Bool = false

@inline AbstractXsdTypes.get_restriction_checks(::Type{TestSimpleType3}) = (
    AbstractXsdTypes.bound_restriction_check,)

export TestSimpleType3

"""
An example of a maxExclusive restricted decimal type.
"""
Base.@kwdef struct TestSimpleType4 <: AbstractXsdTypes.AbstractXSDFloat
    value::Float64
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

@inline AbstractXsdTypes.get_max_value(::Type{TestSimpleType4})::Float64 = 15.22

@inline AbstractXsdTypes.is_max_exclusive(::Type{TestSimpleType4})::Bool = true

@inline AbstractXsdTypes.get_restriction_checks(::Type{TestSimpleType4}) = (
    AbstractXsdTypes.bound_restriction_check,)

export TestSimpleType4

"""
An example of a minInclusive restricted decimal type.
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

@inline AbstractXsdTypes.get_min_value(::Type{TestSimpleType5})::Float64 = -11.6

@inline AbstractXsdTypes.is_min_exclusive(::Type{TestSimpleType5})::Bool = false

@inline AbstractXsdTypes.get_restriction_checks(::Type{TestSimpleType5}) = (
    AbstractXsdTypes.bound_restriction_check,)

export TestSimpleType5

"""
An example of a minExclusive restricted decimal type.
"""
Base.@kwdef struct TestSimpleType6 <: AbstractXsdTypes.AbstractXSDFloat
    value::Float64
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
    function TestSimpleType6(
        value::Number,
        __xml_attributes::Union{Nothing, Dict{String, String}}=nothing,
        __validated::Bool=true)
        if __validated
            AbstractXsdTypes.check_restrictions(TestSimpleType6, value)
        end
        return new(value, __xml_attributes, __validated)
    end
end

@inline AbstractXsdTypes.get_min_value(::Type{TestSimpleType6})::Float64 = -77.8

@inline AbstractXsdTypes.is_min_exclusive(::Type{TestSimpleType6})::Bool = true

@inline AbstractXsdTypes.get_restriction_checks(::Type{TestSimpleType6}) = (
    AbstractXsdTypes.bound_restriction_check,)

export TestSimpleType6

Base.@kwdef struct documentType <: AbstractXsdTypes.AbstractXSDComplex
    TestElement1::TestSimpleType1
    TestElement2::TestSimpleType2
    TestElement3::TestSimpleType3
    TestElement4::TestSimpleType4
    TestElement5::TestSimpleType5
    TestElement6::TestSimpleType6
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export documentType

end

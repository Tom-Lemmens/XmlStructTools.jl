module TestSimpleUnion_struct

import AbstractXsdTypes

module TestDoubleRestrictedDoubleTypes


    import AbstractXsdTypes

    using ..TestSimpleUnion_struct

    Base.@kwdef struct type_1 <: AbstractXsdTypes.AbstractXSDFloat
        value::Float64
        __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
        __validated::Bool = true
        function type_1(
            value::Number,
            __xml_attributes::Union{Nothing, Dict{String, String}}=nothing,
            __validated::Bool=true)
            if __validated
                AbstractXsdTypes.check_restrictions(type_1, value)
            end
            return new(value, __xml_attributes, __validated)
        end
    end

    @inline AbstractXsdTypes.get_max_value(::Type{type_1})::Float64 = 1.0

    @inline AbstractXsdTypes.is_max_exclusive(::Type{type_1})::Bool = false

    @inline AbstractXsdTypes.get_min_value(::Type{type_1})::Float64 = 0.0

    @inline AbstractXsdTypes.is_min_exclusive(::Type{type_1})::Bool = false

    @inline AbstractXsdTypes.get_restriction_checks(::Type{type_1}) = (
        AbstractXsdTypes.bound_restriction_check,)

    Base.@kwdef struct type_2 <: AbstractXsdTypes.AbstractXSDFloat
        value::Float64
        __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
        __validated::Bool = true
        function type_2(
            value::Number,
            __xml_attributes::Union{Nothing, Dict{String, String}}=nothing,
            __validated::Bool=true)
            if __validated
                AbstractXsdTypes.check_restrictions(type_2, value)
            end
            return new(value, __xml_attributes, __validated)
        end
    end

end

export TestDoubleRestrictedDoubleTypes

"""
An example of a union of the same base types.
"""
Base.@kwdef struct TestDoubleRestrictedDouble <: AbstractXsdTypes.AbstractXSDUnion
    value :: Union{TestDoubleRestrictedDoubleTypes.type_1, TestDoubleRestrictedDoubleTypes.type_2}
    __validated::Bool = true
end

AbstractXsdTypes.union_types(::Type{<:TestDoubleRestrictedDouble}) = (TestDoubleRestrictedDoubleTypes.type_1, TestDoubleRestrictedDoubleTypes.type_2)

export TestDoubleRestrictedDouble

module UnionTypeTypes


    import AbstractXsdTypes

    using ..TestSimpleUnion_struct

    Base.@kwdef struct type_1 <: AbstractXsdTypes.AbstractXSDFloat
        value::Float64
        __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
        __validated::Bool = true
        function type_1(
            value::Number,
            __xml_attributes::Union{Nothing, Dict{String, String}}=nothing,
            __validated::Bool=true)
            if __validated
                AbstractXsdTypes.check_restrictions(type_1, value)
            end
            return new(value, __xml_attributes, __validated)
        end
    end

    @inline AbstractXsdTypes.get_max_value(::Type{type_1})::Float64 = 1.0

    @inline AbstractXsdTypes.is_max_exclusive(::Type{type_1})::Bool = false

    @inline AbstractXsdTypes.get_min_value(::Type{type_1})::Float64 = 0.0

    @inline AbstractXsdTypes.is_min_exclusive(::Type{type_1})::Bool = false

    @inline AbstractXsdTypes.get_restriction_checks(::Type{type_1}) = (
        AbstractXsdTypes.bound_restriction_check,)

    Base.@kwdef struct type_2 <: AbstractXsdTypes.AbstractXSDSigned
        value::Int64
        __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
        __validated::Bool = true
    end

end

export UnionTypeTypes

"""
An example of a union of two different types.
"""
Base.@kwdef struct UnionType <: AbstractXsdTypes.AbstractXSDUnion
    value :: Union{UnionTypeTypes.type_1, UnionTypeTypes.type_2}
    __validated::Bool = true
end

AbstractXsdTypes.union_types(::Type{<:UnionType}) = (UnionTypeTypes.type_1, UnionTypeTypes.type_2)

export UnionType

Base.@kwdef struct documentType <: AbstractXsdTypes.AbstractXSDComplex
    TestDoubleRestrictedDouble::TestDoubleRestrictedDouble
    UnionType::UnionType
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export documentType

end

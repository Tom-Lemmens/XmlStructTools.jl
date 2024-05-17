
for simple_test in conversion_simple_types
    for type_name in simple_test.type_pair
        @eval begin
            Base.@kwdef @concrete struct $type_name <: AbstractXsdTypes.$(simple_test.abstract_type)
                value::$(simple_test.value_type)
                __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
                __validated::Bool = true
            end
        end
    end
end

Base.@kwdef @concrete struct ComplexType1 <: AbstractXsdTypes.AbstractXSDComplex
    field_string::String
    field_float::Float64
    field_integer::Int64
    field_unsigned::UInt64
    __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
    __validated::Bool = true
end

Base.@kwdef @concrete struct ComplexType2 <: AbstractXsdTypes.AbstractXSDComplex
    field_string::String
    field_float::Float64
    field_integer::Int64
    field_unsigned::UInt64
    __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
    __validated::Bool = true
end

Base.@kwdef @concrete struct ComplexTypeNoDefault <: AbstractXsdTypes.AbstractXSDComplex
    field_string::String
    field_float::Float64
    field_integer::Int64
    field_unsigned::UInt64
    field_string_default::String
    field_float_default::Float64
    __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
    __validated::Bool = true
end

Base.@kwdef @concrete struct ComplexTypeDefault <: AbstractXsdTypes.AbstractXSDComplex
    field_string::String
    field_float::Float64
    field_integer::Int64
    field_unsigned::UInt64
    field_string_default::String = "aa"
    field_float_default::Float64 = 5
    __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
    __validated::Bool = true
end
AbstractXsdTypes.defaults(::Type{ComplexTypeDefault}) = (field_string_default = "aa", field_float_default = Float64(5))

Base.@kwdef @concrete struct ComplexTypeDifferentDefault <: AbstractXsdTypes.AbstractXSDComplex
    field_string::String
    field_float::Float64
    field_integer::Int64
    field_unsigned::UInt64
    field_string_default::String = "bb"
    field_float_default::Float64 = 1
    __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
    __validated::Bool = true
end
AbstractXsdTypes.defaults(::Type{ComplexTypeDifferentDefault}) =
    (field_string_default = "bb", field_float_default = Float64(1))

Base.@kwdef @concrete struct ComplexTypeAllString <: AbstractXsdTypes.AbstractXSDComplex
    field_string::String
    field_float::String
    field_integer::String
    field_unsigned::String
    __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
    __validated::Bool = true
end

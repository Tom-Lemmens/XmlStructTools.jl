const OptionalAttributes = Union{Nothing,Dict{String,String}}

"""
    AbstractXSDFloat <: AbstractFloat

Must have a `value` field, an `__xml_attributes` field, and a __validated field.

```jldoctest floattype
import AbstractXsdTypes: AbstractXSDFloat

struct FloatType <: AbstractXSDFloat
    value::Float64
    __xml_attributes::Union{Nothing,Dict{String,String}}
    __validated::Bool
end

xsd_float = FloatType(1.0, Dict("x" => "y"), true)
show(xsd_float)

# output

1.0
```
"""
abstract type AbstractXSDFloat <: AbstractFloat end

can_be_converted(from::Type{<:AbstractFloat}, to::Type{<:AbstractXSDFloat}) = true

function Base.promote_rule(::Type{<:AbstractXSDFloat}, ::Type{T}) where {T<:Number}
    return promote_type(Float64, T)
end

"""
    AbstractXSDSigned <: Signed

Must have a `value` field, an `__xml_attributes` field, and a __validated field.

```jldoctest signedtype
import AbstractXsdTypes: AbstractXSDSigned

struct SignedType <: AbstractXSDSigned
    value::Int64
    __xml_attributes::Union{Nothing,Dict{String,String}}
    __validated::Bool
end

xsd_signed = SignedType(1, Dict("x" => "y"), true)
show(xsd_signed)

# output

1
```
"""
abstract type AbstractXSDSigned <: Signed end

can_be_converted(from::Type{<:Signed}, to::Type{<:AbstractXSDSigned}) = true

function Base.promote_rule(::Type{<:AbstractXSDSigned}, ::Type{T}) where {T<:Number}
    return promote_type(Int64, T)
end

Base.flipsign(x::AbstractXSDSigned, y) = flipsign(x.value, y)
Base.flipsign(x::AbstractXSDSigned, y::AbstractXSDSigned) = flipsign(x.value, y.value)
Base.flipsign(x, y::AbstractXSDSigned) = flipsign(x, y.value)

"""
    AbstractXSDUnsigned <: Unsigned

Must have a `value` field, an `__xml_attributes` field, and a __validated field.

```jldoctest unsignedtype
import AbstractXsdTypes: AbstractXSDUnsigned

struct UnsignedType <: AbstractXSDUnsigned
    value::UInt64
    __xml_attributes::Union{Nothing,Dict{String,String}}
    __validated::Bool
end

xsd_unsigned = UnsignedType(0x0000000000000001, Dict("x" => "y"), true)
show(xsd_unsigned)

# output

0x0000000000000001
```
"""
abstract type AbstractXSDUnsigned <: Unsigned end

can_be_converted(from::Type{<:Unsigned}, to::Type{<:AbstractXSDUnsigned}) = true

function Base.promote_rule(::Type{<:AbstractXSDUnsigned}, ::Type{T}) where {T<:Number}
    return promote_type(UInt64, T)
end

Base.leading_zeros(x::AbstractXSDUnsigned) = leading_zeros(x.value)
>>(x::AbstractXSDUnsigned, y::Integer) = x.value >> y
>>(x::AbstractXSDUnsigned, y::AbstractXSDUnsigned) = x.value >> y.value
>>(x::Integer, y::AbstractXSDUnsigned) = x >> y.value

"""
    AbstractXSDString <: AbstractString

Must have a `value` field, an `__xml_attributes` field, and a __validated field.

```jldoctest stringtype
import AbstractXsdTypes: AbstractXSDString

struct StringType <: AbstractXSDString
    value::String
    __xml_attributes::Union{Nothing,Dict{String,String}}
    __validated::Bool
end

xsd_string = StringType("value", Dict("x" => "y"), true)
show(xsd_string)

# output

"value"
```
"""
abstract type AbstractXSDString <: AbstractString end

can_be_converted(from::Type{<:AbstractString}, to::Type{<:AbstractXSDString}) = true

Base.ncodeunits(s::AbstractXSDString) = ncodeunits(s.value)
Base.codeunit(s::AbstractXSDString) = codeunit(s.value)
Base.codeunit(s::AbstractXSDString, i::Integer) = codeunit(s.value, i)
Base.iterate(s::AbstractXSDString, i::Integer) = iterate(s.value, i)
Base.iterate(s::AbstractXSDString) = iterate(s.value)
Base.isvalid(s::AbstractXSDString, i::Integer) = isvalid(s.value, i)

"""
    AbstractXSDComplex

Abstract type used for complex XSD structs.

The contract for concrete subtypes is:

  - each fieldname is an XML element
  - except __xml_attributes, which contains the attributes
  - except __validated, which indicates if the object was validated at construction with respect to the XSD schema

This type has a special `Base.show` which calls `AbstractXsdTypes.print_tree`

```jldoctest simpletype
import AbstractXsdTypes: AbstractXSDComplex

struct SimpleType <: AbstractXSDComplex
    Element1::String
    Element2::Float64
    __xml_attributes::Union{Nothing,Dict{String,String}}
    __validated::Bool
end

simple = SimpleType("value", 1e-3, Dict("x" => "y"), true)
show(simple)

# output

|-- Element1: value
|-- Element2: 0.001
|-- __xml_attributes: Dict("x" => "y")
|-- __validated: true
```
"""
abstract type AbstractXSDComplex end

const private_field_names = (:__xml_attributes, :__validated)

function public_propertynames(::Type{T}) where {T<:AbstractXSDComplex}
    return Tuple(filter(name -> !(name in private_field_names), fieldnames(T)))
end

"""
    AbstractXsdTypes.AbstractXSDUnion

Abstract type used for [XSD Union types](https://xsdata.readthedocs.io/en/v21.3/defxmlschema/chapter10.html).

First field must be the value, which will be another XSD type.

You must use the AbstractXsdTypes.union_value function in the constructor as shown below.
This is to make sure the values get converted to a union value.

You must implement the AbstractXsdTypes.union_types function.

xml attributes will be passed along to the value type.

```julia
Base.@kwdef @concrete struct UnionType <: AbstractXsdTypes.AbstractXSDUnion
    value <: Union{FloatType,AnotherFloatType,StringType}
    __validated::Bool = true
end

AbstractXsdTypes.union_types(::Type{<:UnionType}) = (FloatType, AnotherFloatType, StringType)
```
"""
abstract type AbstractXSDUnion end

# this function must be implemented by the client (XsdToStruct.jl): union_types(::Type{<:AbstractXSDUnion})
union_types(union::AbstractXSDUnion) = union_types(typeof(union))

# AbstractXSDUnion will have a (::Type{T})(value::Union{...}, __validated::Bool) as inner constructor due to @concrete
function (::Type{T})(
    input_value,
    __xml_attributes::OptionalAttributes = nothing,
    validated::Bool = true;
    __validated::Bool = validated,
) where {T<:AbstractXSDUnion}
    value = AbstractXsdTypes.union_value(T, input_value, __xml_attributes, __validated)
    return T(value, value.__validated)
end

(::Type{T})(value, __validated::Bool) where {T<:AbstractXSDUnion} = T(value, nothing, __validated)

function union_value(
    ::Type{T},
    value::V,
    __xml_attributes = nothing,
    __validated::Bool = true,
) where {T<:AbstractXSDUnion,V}
    for possible_type in union_types(T)
        V == possible_type && return value # because it's a perfect match
        # we need to check if we can construct a corresponding XSD type
        if can_be_converted(V, possible_type)
            try
                output = possible_type(value, __xml_attributes, __validated)
                return output
            catch e
                # cannot be converted due to restriction
            end
        end
    end
    return error("value of type $V is not found in the XSD union $T")
end

# Collections of XSD types
const AbstractXSDNumericTypes = Union{AbstractXSDFloat,AbstractXSDUnsigned,AbstractXSDSigned}
const AbstractXSDSimpleTypes = Union{AbstractXSDNumericTypes,AbstractXSDString}
const AbstractXSDSimpleUnionTypes = Union{AbstractXSDSimpleTypes,AbstractXSDUnion}
const AbstractXSDAllTypes = Union{AbstractXSDSimpleTypes,AbstractXSDComplex,AbstractXSDUnion}

# default implementation
can_be_converted(from::Type, to::Type) = false

Base.convert(::Type{T}, value) where {T<:AbstractXSDUnion} = T(value)
Base.convert(::Type{T}, union::AbstractXSDUnion) where {T} = convert(T, union.value)

public_propertynames(::Type{T}) where {T<:AbstractXSDSimpleUnionTypes} = (:value,)

number_of_public_properties(::Type{T}) where {T<:AbstractXSDAllTypes} = length(public_propertynames(T))

# Complex types are complex
function (::Type{T})(
    values::Vararg{<:Any,N_input};
    __xml_attributes = nothing,
    __validated = true,
) where {T<:AbstractXSDComplex,N_input}
    N_public = number_of_public_properties(T)
    if N_public == N_input
        public_values = values
        __xml_attributes_input = __xml_attributes
        __validated_input = __validated
    elseif N_input == N_public + 1 && values[end] isa Bool
        public_values = values[1:(end - 1)]
        __xml_attributes_input = __xml_attributes
        __validated_input = values[end]
    elseif N_input == N_public + 2
        public_values = values[1:(end - 2)]
        __xml_attributes_input = values[end - 1]
        __validated_input = values[end]
    else
        throw(MethodError(T, values))
    end
    return T(public_values..., __xml_attributes_input, __validated_input)
end

"""
    AbstractXsdTypes.defaults(::Type{MyType}) = (:field_a=default_value, :field_b=>default_value)

Define default arguments for various fields of `MyType`, which will be generated by XsdToStruct and can be used by your
custom XML parser.
"""
function defaults end

defaults(x::T) where {T} = defaults(T)
defaults(::Type{T}) where {T} = NamedTuple()

# possible definition of a default getter
# you can also do `get(defaults(T), field_name, nothing)` to make nothing the default
getdefault(::Type{T}, field_name::Symbol) where {T} = getindex(defaults(T), field_name)
getdefault(::Type{T}, field_index::Integer) where {T} = getdefault(T, fieldname(T, field_index))

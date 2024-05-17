module TestChoice_struct

import AbstractXsdTypes

"""
Example of a complex XSD type that uses a choice.
"""
struct TestComplexType1 <: AbstractXsdTypes.AbstractXSDComplex
    element1::String
    __TestComplexType1_choice_1::NamedTuple{(:choice1, :choice2), Tuple{Union{String, Nothing}, Union{Float64, Nothing}}}
    element2::String
    __xml_attributes::Union{Nothing, Dict{String, String}}
    __validated::Bool
end

AbstractXsdTypes.defaults(::Type{TestComplexType1}) = (element2 = String("default"), )

function TestComplexType1(;
    element1::String,
    choice1::Union{String, Nothing}=nothing,
    choice2::Union{Float64, Nothing}=nothing,
    element2::String,
    __xml_attributes::Union{Nothing, Dict{<:AbstractString, <:AbstractString}} = nothing,
    __validated::Bool = true)

    if count(!isnothing, [choice1, choice2]) > 1
        error("Only one of choice1 or choice2 can be not nothing")
    else
        TestComplexType1(element1, (choice1=choice1, choice2=choice2), element2, __xml_attributes, __validated)
    end
end

Base.propertynames(x::TestComplexType1, private::Bool=false) = Tuple(append!(
    filter(s->!startswith(String(s), "__TestComplexType1"), collect(fieldnames(TestComplexType1))),
    [:choice1, :choice2]))
function Base.getproperty(x::TestComplexType1, s::Symbol)
    if s in [:choice1, :choice2]
        return getfield(getfield(x, Symbol("__TestComplexType1_choice_1")), s)
    else
        return getfield(x, s)
    end
end

export TestComplexType1

module TestComplexType2Types


    import AbstractXsdTypes

    using ..TestChoice_struct

    """
    An example of a simple xsd type.
    """
    Base.@kwdef struct choice3 <: AbstractXsdTypes.AbstractXSDString
        value::String
        __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
        __validated::Bool = true
        function choice3(
            value::AbstractString,
            __xml_attributes::Union{Nothing, Dict{String, String}}=nothing,
            __validated::Bool=true)
            if __validated
                AbstractXsdTypes.check_restrictions(choice3, value)
            end
            return new(value, __xml_attributes, __validated)
        end
    end

end

export TestComplexType2Types

"""
Example of a complex XSD type that uses a choice.
"""
struct TestComplexType2 <: AbstractXsdTypes.AbstractXSDComplex
    __TestComplexType2_choice_1::NamedTuple{(:choice1, :choice2, :choice3), Tuple{Union{String, Nothing}, Union{Float64, Nothing}, Union{TestComplexType2Types.choice3, Nothing}}}
    __xml_attributes::Union{Nothing, Dict{String, String}}
    __validated::Bool
end

function TestComplexType2(;
    choice1::Union{String, Nothing}=nothing,
    choice2::Union{Float64, Nothing}=nothing,
    choice3::Union{TestComplexType2Types.choice3, Nothing}=nothing,
    __xml_attributes::Union{Nothing, Dict{<:AbstractString, <:AbstractString}} = nothing,
    __validated::Bool = true)

    if count(!isnothing, [choice1, choice2, choice3]) > 1
        error("Only one of choice1 or choice2 or choice3 can be not nothing")
    else
        TestComplexType2((choice1=choice1, choice2=choice2, choice3=choice3), __xml_attributes, __validated)
    end
end

Base.propertynames(x::TestComplexType2, private::Bool=false) = Tuple(append!(
    filter(s->!startswith(String(s), "__TestComplexType2"), collect(fieldnames(TestComplexType2))),
    [:choice1, :choice2, :choice3]))
function Base.getproperty(x::TestComplexType2, s::Symbol)
    if s in [:choice1, :choice2, :choice3]
        return getfield(getfield(x, Symbol("__TestComplexType2_choice_1")), s)
    else
        return getfield(x, s)
    end
end

export TestComplexType2

"""
Example of a complex XSD type that uses a choice.
"""
struct TestComplexType5 <: AbstractXsdTypes.AbstractXSDComplex
    __TestComplexType5_choice_1::NamedTuple{(:choice1, :choice2), Tuple{Union{String, Nothing}, Union{Float64, Nothing}}}
    __TestComplexType5_choice_2::NamedTuple{(:choice3, :choice4), Tuple{Union{String, Nothing}, Union{Float64, Nothing}}}
    __xml_attributes::Union{Nothing, Dict{String, String}}
    __validated::Bool
end

function TestComplexType5(;
    choice1::Union{String, Nothing}=nothing,
    choice2::Union{Float64, Nothing}=nothing,
    choice3::Union{String, Nothing}=nothing,
    choice4::Union{Float64, Nothing}=nothing,
    __xml_attributes::Union{Nothing, Dict{<:AbstractString, <:AbstractString}} = nothing,
    __validated::Bool = true)

    if count(!isnothing, [choice1, choice2]) > 1
        error("Only one of choice1 or choice2 can be not nothing")
    elseif count(!isnothing, [choice3, choice4]) > 1
        error("Only one of choice3 or choice4 can be not nothing")
    else
        TestComplexType5((choice1=choice1, choice2=choice2), (choice3=choice3, choice4=choice4), __xml_attributes, __validated)
    end
end

Base.propertynames(x::TestComplexType5, private::Bool=false) = Tuple(append!(
    filter(s->!startswith(String(s), "__TestComplexType5"), collect(fieldnames(TestComplexType5))),
    [:choice1, :choice2, :choice3, :choice4]))
function Base.getproperty(x::TestComplexType5, s::Symbol)
    if s in [:choice1, :choice2]
        return getfield(getfield(x, Symbol("__TestComplexType5_choice_1")), s)
    elseif s in [:choice3, :choice4]
        return getfield(getfield(x, Symbol("__TestComplexType5_choice_2")), s)
    else
        return getfield(x, s)
    end
end

export TestComplexType5

Base.@kwdef struct documentType <: AbstractXsdTypes.AbstractXSDComplex
    TestElement1::TestComplexType1
    TestElement2::TestComplexType2
    TestElement5::TestComplexType5
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export documentType

end

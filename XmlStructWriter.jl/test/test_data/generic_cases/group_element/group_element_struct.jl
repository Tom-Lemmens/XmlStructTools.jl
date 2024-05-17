module TestGroup_struct

import AbstractXsdTypes

"""
Example of a complex XSD type that uses a group.
"""
Base.@kwdef struct TestComplexType1 <: AbstractXsdTypes.AbstractXSDComplex
    Element_string::String
    Element_double::Float64
    Element_boolean::Bool
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export TestComplexType1

"""
Example of a complex XSD type that uses a group and an element.
"""
Base.@kwdef struct TestComplexType2 <: AbstractXsdTypes.AbstractXSDComplex
    Element_string::String
    Element_double::Float64
    Element_boolean::Bool
    Element_boolean_second::Bool
    Element_string_2::String
    Element_double_2::Float64
    Element_boolean_2::Bool
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export TestComplexType2

"""
Example of a complex XSD type that uses a nested group.
"""
Base.@kwdef struct TestComplexType3 <: AbstractXsdTypes.AbstractXSDComplex
    Element_string::String
    Element_double::Float64
    Element_boolean::Bool
    Element_boolean2::Bool
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export TestComplexType3

Base.@kwdef struct documentType <: AbstractXsdTypes.AbstractXSDComplex
    TestElement1::TestComplexType1
    TestElement2::TestComplexType2
    TestElement3::TestComplexType3
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export documentType

end

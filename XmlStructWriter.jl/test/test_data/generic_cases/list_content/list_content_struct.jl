module TestList_struct

import AbstractXsdTypes

"""
An example of a complex xsd type with an unbounded list.
"""
Base.@kwdef struct TestComplexType1 <: AbstractXsdTypes.AbstractXSDComplex
    Element_list_double::Vector{Float64}
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export TestComplexType1

"""
An example of a complex xsd type with a bounded list.
"""
Base.@kwdef struct TestComplexType2 <: AbstractXsdTypes.AbstractXSDComplex
    Element_list_string::Vector{String}
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export TestComplexType2

"""
An example of a complex xsd type with no list.
"""
Base.@kwdef struct TestComplexType4 <: AbstractXsdTypes.AbstractXSDComplex
    Element_string::String
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export TestComplexType4

"""
An example of a complex xsd type with no list.
"""
Base.@kwdef struct TestComplexType5 <: AbstractXsdTypes.AbstractXSDComplex
    Element_string::String
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export TestComplexType5

"""
An example of a complex xsd type with no list.
"""
Base.@kwdef struct TestComplexType3 <: AbstractXsdTypes.AbstractXSDComplex
    Element_type4_list::Vector{TestComplexType4}
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export TestComplexType3

Base.@kwdef struct documentType <: AbstractXsdTypes.AbstractXSDComplex
    TestElement1::TestComplexType1
    TestElement2::TestComplexType2
    TestElement3::TestComplexType3
    TestElement5::TestComplexType5
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export documentType

end

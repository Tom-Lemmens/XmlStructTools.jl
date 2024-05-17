module TestTypeInType_struct

using Reexport
@reexport using Dates
@reexport using TimeZones
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

module TestComplexType1Types


    import AbstractXsdTypes

    using ..TestTypeInType_struct

    """
    An example of a complex xsd type.
    """
    Base.@kwdef struct A <: AbstractXsdTypes.AbstractXSDComplex
        Element_string::String
        Element_double::Float64
        Element_boolean::Bool
        Element_dateTime::Union{ZonedDateTime, DateTime}
        __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
        __validated::Bool = true
    end

    """
    An example of an extended simple xsd type.
    """
    Base.@kwdef struct B <: AbstractXsdTypes.AbstractXSDString
        value::TestSimpleType1
        __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
        __validated::Bool = true
    end

    """
    An example of a complex xsd type.
    """
    Base.@kwdef struct C <: AbstractXsdTypes.AbstractXSDComplex
        Element_string::String
        Element_double::Float64
        Element_boolean::Bool
        Element_dateTime::Union{ZonedDateTime, DateTime}
        __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
        __validated::Bool = true
    end

end

export TestComplexType1Types

"""
Example of a complex XSD type that uses types defined under it's elements.
"""
Base.@kwdef struct TestComplexType1 <: AbstractXsdTypes.AbstractXSDComplex
    A::TestComplexType1Types.A
    B::TestComplexType1Types.B
    C::TestComplexType1Types.C
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export TestComplexType1

"""
An example of a simple xsd type.
"""
Base.@kwdef struct TestSimpleType2 <: AbstractXsdTypes.AbstractXSDString
    value::String
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

module TestComplexType3Types


    import AbstractXsdTypes

    using ..TestTypeInType_struct

    """
    An example of an extended simple xsd type.
    """
    Base.@kwdef struct A <: AbstractXsdTypes.AbstractXSDString
        value::TestSimpleType1
        __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
        __validated::Bool = true
    end

    """
    An example of an extended simple xsd type.
    """
    Base.@kwdef struct B <: AbstractXsdTypes.AbstractXSDString
        value::TestSimpleType2
        __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
        __validated::Bool = true
    end

end

export TestComplexType3Types

"""
Example of a complex XSD type that uses a mix of types defined under it's elements and normal types in a particular order.
"""
Base.@kwdef struct TestComplexType3 <: AbstractXsdTypes.AbstractXSDComplex
    A::TestComplexType3Types.A
    S1::TestSimpleType2
    B::TestComplexType3Types.B
    S2::TestSimpleType2
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export TestComplexType3

module TestComplexType2Types


    import AbstractXsdTypes

    using ..TestTypeInType_struct

    """
    An example of an extended simple xsd type.
    """
    Base.@kwdef struct A <: AbstractXsdTypes.AbstractXSDString
        value::TestSimpleType1
        __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
        __validated::Bool = true
    end

    """
    An example of an extended simple xsd type.
    """
    Base.@kwdef struct B <: AbstractXsdTypes.AbstractXSDString
        value::TestSimpleType2
        __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
        __validated::Bool = true
    end

end

export TestComplexType2Types

"""
Example of a complex XSD type that uses types defined under it's elements and depends on a type defined later in the xsd.
"""
Base.@kwdef struct TestComplexType2 <: AbstractXsdTypes.AbstractXSDComplex
    A::TestComplexType2Types.A
    B::TestComplexType2Types.B
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export TestComplexType2

Base.@kwdef struct documentType <: AbstractXsdTypes.AbstractXSDComplex
    TestElement1::TestComplexType1
    TestElement2::TestComplexType2
    TestElement3::TestComplexType3
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export documentType

end

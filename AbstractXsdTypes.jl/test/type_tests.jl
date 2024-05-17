
@testset "AbstractXSDComplex" begin
    struct SimpleType <: AbstractXsdTypes.AbstractXSDComplex
        Element1::String
        Element2::Float64
        __xml_attributes::Union{Nothing,Dict{String,String}}
        __validated::Bool
    end

    attr = Dict("x" => "y")
    simple = SimpleType("value", 1e-3, attr, false)
    @test simple.__xml_attributes === attr
    @test simple.__validated == false

    simple = SimpleType("value", 1e-3; __xml_attributes = attr, __validated = false)
    @test simple.__xml_attributes === attr
    @test simple.__validated == false

    simple = SimpleType("value", 1e-3, false; __xml_attributes = attr)
    @test simple.__xml_attributes === attr
    @test simple.__validated == false

    simple = SimpleType("value", 1e-3)
    @test simple.__xml_attributes === nothing
    @test simple.__validated == true

    simple = SimpleType("value", 1e-3, false)
    @test simple.__xml_attributes === nothing
    @test simple.__validated == false

    simple = SimpleType("value", 1e-3; __validated = false)
    @test simple.__xml_attributes === nothing
    @test simple.__validated == false

    @test_throws MethodError SimpleType("value", 1e-3, 5)
    @test_throws MethodError SimpleType("value")

    @test propertynames(simple, true) == (:Element1, :Element2, :__xml_attributes, :__validated)
end

module UnionModule
using AbstractXsdTypes
using ConcreteStructs

Base.@kwdef struct FloatType <: AbstractXsdTypes.AbstractXSDFloat
    value::Float64 = AbstractXsdTypes.getdefault(FloatType, :value)
    __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
    __validated::Bool = true
    function FloatType(value::Float64, __xml_attributes, __validated)
        if __validated
            AbstractXsdTypes.check_restrictions(FloatType, value)
        end
        return new(value, __xml_attributes, __validated)
    end
end

# adding a restriction
AbstractXsdTypes.get_max_value(::Type{FloatType})::Int = 5.0
AbstractXsdTypes.is_max_exclusive(::Type{FloatType})::Bool = false
AbstractXsdTypes.get_restriction_checks(::Type{FloatType})::Tuple{Function} =
    (AbstractXsdTypes.bound_restriction_check,)

AbstractXsdTypes.defaults(::Type{FloatType}) = (value = 0.0,)

Base.@kwdef @concrete struct AnotherFloatType <: AbstractXsdTypes.AbstractXSDFloat
    value::Float64
    __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
    __validated::Bool = true
end

Base.@kwdef @concrete struct StringType <: AbstractXsdTypes.AbstractXSDString
    value::String = ""
    __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
    __validated::Bool = true
end

Base.@kwdef @concrete struct UnionType <: AbstractXsdTypes.AbstractXSDUnion
    value <: Union{FloatType,AnotherFloatType,StringType}
    __validated::Bool = true
end

AbstractXsdTypes.union_types(::Type{<:UnionType}) = (FloatType, AnotherFloatType, StringType)

Base.@kwdef @concrete struct ComplexType <: AbstractXsdTypes.AbstractXSDComplex
    Element1::String
    Element2::FloatType
    __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
    __validated::Bool = true
end

Base.@kwdef @concrete struct UnionTypeWithComplex <: AbstractXsdTypes.AbstractXSDUnion
    value <: Union{FloatType,ComplexType}
    __validated::Bool = true
end

AbstractXsdTypes.union_types(::Type{<:UnionTypeWithComplex}) = (FloatType, ComplexType)

Base.@kwdef @concrete struct ComplexTypeWithUnion <: AbstractXsdTypes.AbstractXSDComplex
    Element_Union::UnionType
    Element2::FloatType
    __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
    __validated::Bool = true
end
end
import .UnionModule as UM

@testset "AbstractXSDUnion" begin
    # check the FloatType restriction works
    @test_throws AbstractXsdTypes.XSDValueRestrictionViolationError UM.FloatType(6.0)

    xsd_value = UM.FloatType(1.0)
    union = UM.UnionType(xsd_value)
    @test union.value == xsd_value

    # check validated is taken from the xsd_value
    xsd_value = UM.FloatType(1.0, false)
    union = UM.UnionType(xsd_value)
    @test union.value == xsd_value
    @test union.__validated == false

    union = UM.UnionType(1.0)
    @test union.value isa UM.FloatType
    @test union.value.value == 1.0

    # another constructor variation
    attr = Dict{String,String}("x" => "y")
    union = UM.UnionType(1.0, attr)
    @test union.value isa UM.FloatType
    @test union.value.value == 1.0
    @test union.value.__xml_attributes === attr

    # going over the restriction
    union = UM.UnionType(6.0)
    @test union.value isa UM.AnotherFloatType
    @test union.value.value == 6.0

    # no restriction checks
    union = UM.UnionType(6.0, nothing, false)
    @test union.value isa UM.FloatType
    @test union.value.value == 6.0
    @test union.value.__validated == false

    # call the default constructor
    attr = Dict{String,String}("x" => "y")
    xsd_value = UM.FloatType(2.0, attr, false)
    union = UM.UnionType(xsd_value, false)
    @test union.value === xsd_value

    # pass attributes over the constructor
    attr = Dict{String,String}("x" => "y")
    union = UM.UnionType(6.0, attr, false)
    @test union.value.__xml_attributes === attr
    @test !union.value.__validated

    union = UM.UnionType("string")
    @test union.value == UM.StringType("string")

    # no integer in the union!
    msg = "value of type Int64 is not found in the XSD union Main.AbstractXsdTypesTests.UnionModule.UnionType"
    @test_throws ErrorException(msg) UM.UnionType(1)

    union = convert(UM.UnionType, 1.0)
    @test union isa UM.UnionType
    @test union == UM.UnionType(1.0)

    u = convert(UM.UnionType, union)
    @test u === union

    value = convert(Float64, union)
    @test value isa Float64
    @test value == 1.0

    complex = UM.ComplexTypeWithUnion(1.0, 2.0)
    @test complex.Element_Union isa UM.UnionType
    @test complex.Element_Union.value isa AbstractFloat

    complex = UM.ComplexTypeWithUnion("string", 2.0)
    @test complex.Element_Union isa UM.UnionType
    @test complex.Element_Union.value isa AbstractString

    c = UM.ComplexType("string", 1.0)
    union = UM.UnionTypeWithComplex(c)
    @test union.value == c

    union = UM.UnionTypeWithComplex(1.0)
    @test union.value isa AbstractFloat
end

@testset "defaults" begin
    @test AbstractXsdTypes.defaults(UnionModule.AnotherFloatType) == NamedTuple()
    @test AbstractXsdTypes.defaults(UnionModule.FloatType).value == 0.0
    @test AbstractXsdTypes.getdefault(UnionModule.FloatType, :value) == 0.0
end

@testset "vector show" begin
    c1 = UM.ComplexType("string", 1.0)
    c2 = UM.ComplexType("string2", 2.0)
    showed_string = sprint(show, [c1, c2])
    @test contains(showed_string, "2-element Vector{$(typeof(c1))}")
end

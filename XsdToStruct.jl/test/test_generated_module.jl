
@testset "test generated modules" begin
    @testset "test generated basic_types" begin
        include(joinpath(generic_data_dir, "basic_types", "basic_types.jl"))
        import .TestComplexAndSimple

        complex = TestComplexAndSimple.TestComplexType1(
            "Element_string",
            1e-5,
            false,
            1e-5,
            ZonedDateTime(2014, 5, 30, 21, tz"UTC-4"),
            -5,
            UInt64(5),
            UInt64(8),
        )
        @test complex isa TestComplexAndSimple.TestComplexType1

        complex2 = TestComplexAndSimple.TestComplexType6("Element_string", 1e-5, DateTime(2014, 5, 30, 21))
        @test complex2 isa TestComplexAndSimple.TestComplexType6

        simple = TestComplexAndSimple.TestSimpleType1("value")
        @test simple isa TestComplexAndSimple.TestSimpleType1

        doc_type = TestComplexAndSimple.documentType(complex, simple, complex2)
        @test doc_type isa TestComplexAndSimple.documentType
    end

    @testset "test generated choice_element" begin
        include(joinpath(generic_data_dir, "choice_element", "choice_element.jl"))
        import .TestChoice

        complex_1 =
            TestChoice.TestComplexType1(element1 = "Element_string", choice1 = "choice1", element2 = "Element_string")
        @test complex_1 isa TestChoice.TestComplexType1

        complex_2 = TestChoice.TestComplexType2(
            choice3 = TestChoice.TestComplexType2Types.choice3("choice3"),  # Should eventually just be "choice3"
        )
        @test complex_2 isa TestChoice.TestComplexType2

        complex_5 = TestChoice.TestComplexType5(
            choice2 = Float64(22),  # Should eventually just be 22
            choice3 = "choice3",
        )
        @test complex_5 isa TestChoice.TestComplexType5

        doc_type = TestChoice.documentType(complex_1, complex_2, complex_5)
        @test doc_type isa TestChoice.documentType
    end

    @testset "test generated complex_content" begin
        include(joinpath(generic_data_dir, "complex_content", "complex_content.jl"))
        import .TestComplexContent
        test_element_2 = TestComplexContent.TestComplexType2(
            Element_string = "",
            Element_double = 5.5,
            Element_boolean = true,
            Element_decimal = 5.5,
            Element_dateTime = ZonedDateTime(5, 5, 5, tz"UTC"),
            Element_integer = 5,
            Element_nonNegativeInteger = 5,
            Element_positiveInteger = 5,
            Element_integer_ext = 5,
            Element_boolean_ext = true,
        )
        @test test_element_2 isa TestComplexContent.TestComplexType2

        test_element_3 = TestComplexContent.TestComplexType3(
            Element_string = "",
            Element_double = 5.5,
            Element_boolean = true,
            Element_decimal = 5.5,
            Element_dateTime = ZonedDateTime(5, 5, 5, tz"UTC"),
            Element_integer = 5,
            Element_nonNegativeInteger = 5,
            Element_positiveInteger = 5,
        )
        @test test_element_3 isa TestComplexContent.TestComplexType3

        test_element_5 = TestComplexContent.TestComplexType5(5)
        @test test_element_5 isa TestComplexContent.TestComplexType5

        doc_type = TestComplexContent.documentType(test_element_2, test_element_3, test_element_5)
        @test doc_type isa TestComplexContent.documentType
    end

    @testset "test generated optional_elements" begin
        include(joinpath(generic_data_dir, "optional_elements", "optional_elements.jl"))
        import .OptionalElements

        complex1 = OptionalElements.TestComplexType1(
            Element_string = "Element_string",
            Element_double = 1.23456,
            Element_simple1 = 7.89,
        )
        @test complex1 isa OptionalElements.TestComplexType1

        complex2 = OptionalElements.TestComplexType2(;
            OptionalElements.AbstractXsdTypes.defaults(OptionalElements.TestComplexType2)...,
        )
        @test complex2 isa OptionalElements.TestComplexType2

        complex3_defaults = OptionalElements.AbstractXsdTypes.defaults(OptionalElements.TestComplexType3)
        complex3 = OptionalElements.TestComplexType3(
            Element_simple1 = fill(complex3_defaults.Element_simple1, 10),
            Element_simple2 = ["Element_string", "Element_string", "Element_string"],
        )
        @test complex3 isa OptionalElements.TestComplexType3

        complex4_defaults = OptionalElements.AbstractXsdTypes.defaults(OptionalElements.TestComplexType4_element)
        complex4 = OptionalElements.TestComplexType4(
            Element_complex4 = [
                OptionalElements.TestComplexType4_element(
                    Element_simple1_2 = complex4_defaults.Element_simple1_2,
                    Element_simple2_2 = complex4_defaults.Element_simple2_2,
                ),
                OptionalElements.TestComplexType4_element(
                    Element_simple1_1 = 1.23,
                    Element_simple1_2 = OptionalElements.TestSimpleType1(4.56),
                    Element_simple2_1 = OptionalElements.TestSimpleType2("ABCD"),
                    Element_simple2_2 = "EFGH",
                ),
            ],
        )
        @test complex4 isa OptionalElements.TestComplexType4

        complex5_defaults = OptionalElements.AbstractXsdTypes.defaults(OptionalElements.TestComplexType5)
        complex5 = OptionalElements.TestComplexType5(
            Element_simple1 = nothing,
            Element_simple2 = complex5_defaults.Element_simple2,
        )

        @test complex5 isa OptionalElements.TestComplexType5

        complex6_defaults = OptionalElements.AbstractXsdTypes.defaults(OptionalElements.TestComplexType6)
        complex6 = OptionalElements.TestComplexType6(
            Element_simple1 = complex6_defaults.Element_simple1,
            Element_simple2 = nothing,
            Element_simple3 = complex6_defaults.Element_simple3,
            Element_simple4 = complex6_defaults.Element_simple4,
            Element_simple5 = complex6_defaults.Element_simple5,
        )

        @test complex6 isa OptionalElements.TestComplexType6

        doc_type = OptionalElements.documentType(
            TestElement1 = complex1,
            TestElement2 = complex2,
            TestElement3 = complex3,
            TestElement4 = complex4,
            TestElement5 = complex5,
            TestElement6 = complex6,
        )
        @test doc_type isa OptionalElements.documentType
    end

    @testset "test generated type_in_element" begin
        include(joinpath(generic_data_dir, "type_in_element", "type_in_element.jl"))
        import .TestTypeInElement

        simple_2 = TestTypeInElement.documentTypeTypes.TestSimple2("aaa")
        @test simple_2 isa TestTypeInElement.documentTypeTypes.TestSimple2

        complex_1 = TestTypeInElement.documentTypeTypes.TestComplex1(
            Element_string = "bbb",
            Element_double = 5.5,
            Element_boolean = false,
        )
        @test complex_1 isa TestTypeInElement.documentTypeTypes.TestComplex1

        complex_2 = TestTypeInElement.documentTypeTypes.TestComplex2("ccc")
        @test complex_2 isa TestTypeInElement.documentTypeTypes.TestComplex2

        complex_3 = TestTypeInElement.documentTypeTypes.TestComplex3(7.7)
        @test complex_3 isa TestTypeInElement.documentTypeTypes.TestComplex3

        doc_type = TestTypeInElement.documentType(
            TestSimple2 = simple_2,
            TestComplex1 = complex_1,
            TestComplex2 = complex_2,
            TestComplex3 = complex_3,
        )
        @test doc_type isa TestTypeInElement.documentType
    end

    @testset "test generated type_in_type" begin
        include(joinpath(generic_data_dir, "type_in_type", "type_in_type.jl"))
        import .TestTypeInType

        a_element = TestTypeInType.TestComplexType1Types.A(
            Element_string = "000",
            Element_double = 0.75,
            Element_boolean = true,
            Element_dateTime = ZonedDateTime(1, 2, 3, tz"UTC"),
        )
        @test a_element isa TestTypeInType.TestComplexType1Types.A

        b_element = TestTypeInType.TestComplexType1Types.B(value = "aaa")
        @test b_element isa TestTypeInType.TestComplexType1Types.B

        c_element = TestTypeInType.TestComplexType1Types.C(
            Element_string = "000",
            Element_double = 0.75,
            Element_boolean = true,
            Element_dateTime = DateTime(1, 2, 3),
        )
        @test a_element isa TestTypeInType.TestComplexType1Types.A
        complex1 = TestTypeInType.TestComplexType1(A = a_element, B = b_element, C = c_element)
        @test complex1 isa TestTypeInType.TestComplexType1

        complex2 = TestTypeInType.TestComplexType2(A = "a_value", B = "b_value")
        @test complex2 isa TestTypeInType.TestComplexType2

        complex3 = TestTypeInType.TestComplexType3(A = "a_value", S1 = "S1_value", B = "b_value", S2 = "S2_value")
        @test complex3 isa TestTypeInType.TestComplexType3

        doc_type =
            TestTypeInType.documentType(TestElement1 = complex1, TestElement2 = complex2, TestElement3 = complex3)
        @test doc_type isa TestTypeInType.documentType
    end

    @testset "test generated union" begin
        include(joinpath(generic_data_dir, "union_types", "union_types.jl"))
        import .TestSimpleUnion

        float_type = TestSimpleUnion.UnionTypeTypes.type_1(1.0)
        @test float_type.value ≈ 1.0

        attr = Dict{String,String}("x" => "y")
        float_type = TestSimpleUnion.UnionTypeTypes.type_1(1.0, attr, false)
        t = TestSimpleUnion.UnionType(float_type, float_type.__validated)
        @test !t.__validated
        @test t.value === float_type

        t = TestSimpleUnion.UnionType(1.0)
        @test t isa TestSimpleUnion.UnionType
        @test t.value.__xml_attributes === nothing
        @test t.value.__validated

        attr = Dict{String,String}("x" => "y")
        t = TestSimpleUnion.UnionType(1.0, attr, false)
        @test !t.__validated
        @test t.value.__xml_attributes === attr
        @test !t.value.__validated

        d = TestSimpleUnion.documentType(1.0, 1.0)
        @test d.UnionType.value isa AbstractFloat

        d = TestSimpleUnion.documentType(1.0, 1)
        @test d.UnionType.value isa Signed

        d = TestSimpleUnion.documentType(1.0, TestSimpleUnion.UnionTypeTypes.type_2(2))
        @test d.UnionType.value isa TestSimpleUnion.UnionTypeTypes.type_2
        @test d.UnionType.value.value == 2
    end
end


const conversion_simple_types = [
    (
        abstract_type = :AbstractXSDFloat,
        value_type = :Float64,
        type_pair = (:FloatType1 => :FloatType2),
        value_pair = (1.0 => 2.5),
    ),
    (
        abstract_type = :AbstractXSDSigned,
        value_type = :Int64,
        type_pair = (:SignedType1 => :SignedType2),
        value_pair = (1 => 2),
    ),
    (
        abstract_type = :AbstractXSDUnsigned,
        value_type = :UInt64,
        type_pair = (:UnSignedType1 => :UnSignedType2),
        value_pair = (0x0000000000000001 => 0x0000000000000002),
    ),
    (
        abstract_type = :AbstractXSDString,
        value_type = :String,
        type_pair = (:StringType1 => :StringType2),
        value_pair = ("a" => "5"),
    ),
]

if VERSION < v"1.8"
    EXPECTED_THROWS_METHOD = MethodError
else
    EXPECTED_THROWS_METHOD = "MethodError: Cannot `convert`"
end

if VERSION < v"1.8"
    EXPECTED_THROWS_CANNOT_CONVERT(::Any, ::Any) = ErrorException
else
    EXPECTED_THROWS_CANNOT_CONVERT(type1, type2) = "Type $type1 cannot be converted to type $type2"
end

include("conversion_tests_types.jl")

@testset "automatic conversions - simple types" begin
    @testset "simple types - $(simple_test.abstract_type)" for simple_test in conversion_simple_types
        value_1 = first(simple_test.value_pair)
        value_2 = last(simple_test.value_pair)
        @eval begin
            type_1 = $(first(simple_test.type_pair))
            type_2 = $(last(simple_test.type_pair))
        end
        variable_1 = type_1(value_1)
        variable_2 = type_2(value_2)

        @test begin
            convert_1 = convert(type_2, variable_1)
            convert_1 isa type_2
        end
        @test begin
            convert_2 = convert(type_1, variable_2)
            convert_2 isa type_1
        end
    end
end

@testset "automatic conversions - complex types" begin
    @testset "complex types - ComplexType1 and ComplexType2" begin
        args = ["aa", 5.5, 5, 7]

        variable_1 = ComplexType1(args...)
        variable_2 = ComplexType2(args...)

        @test begin
            convert_1 = convert(ComplexType2, variable_1)
            convert_1 isa ComplexType2
        end
        @test begin
            convert_2 = convert(ComplexType1, variable_2)
            convert_2 isa ComplexType1
        end
    end

    @testset "complex types - ComplexType1 and ComplexTypeNoDefault" begin
        variable_1 = ComplexType1("aa", 5.5, 5, 7)
        variable_2 = ComplexTypeNoDefault("aa", 5.5, 5, 7, "bb", 11.1)

        # Incompatible conversions
        @test_throws EXPECTED_THROWS_CANNOT_CONVERT(ComplexType1, ComplexTypeNoDefault) begin
            convert(ComplexTypeNoDefault, variable_1)
        end
        @test_throws EXPECTED_THROWS_CANNOT_CONVERT(ComplexTypeNoDefault, ComplexType1) begin
            convert(ComplexType1, variable_2)
        end
    end

    @testset "complex types - ComplexType1 and ComplexTypeDefault" begin
        variable_1 = ComplexType1("aa", 5.5, 5, 7)
        variable_2 = ComplexTypeDefault(field_string = "aa", field_float = 5.5, field_integer = 5, field_unsigned = 7)

        @test begin
            convert_1 = convert(ComplexTypeDefault, variable_1)
            convert_1 isa ComplexTypeDefault
        end

        # Incompatible conversion
        @test_throws EXPECTED_THROWS_CANNOT_CONVERT(ComplexTypeDefault, ComplexType1) begin
            convert(ComplexType1, variable_2)
        end
    end

    @testset "complex types - ComplexType1 and ComplexTypeDifferentDefault" begin
        variable_1 = ComplexType1("aa", 5.5, 5, 7)
        variable_2 =
            ComplexTypeDifferentDefault(field_string = "aa", field_float = 5.5, field_integer = 5, field_unsigned = 7)

        @test begin
            convert_1 = convert(ComplexTypeDifferentDefault, variable_1)
            convert_1 isa ComplexTypeDifferentDefault
        end

        # Incompatible conversion
        @test_throws EXPECTED_THROWS_CANNOT_CONVERT(ComplexTypeDifferentDefault, ComplexType1) begin
            convert(ComplexType1, variable_2)
        end
    end

    @testset "complex types - ComplexType1 and ComplexTypeAllString" begin
        variable_1 = ComplexType1("aa", 5.5, 5, 7)
        variable_2 = ComplexTypeAllString("aa", "5.5", "5", "7")

        # Incompatible conversions
        @test_throws EXPECTED_THROWS_METHOD begin
            convert(ComplexTypeAllString, variable_1)
        end
        @test_throws EXPECTED_THROWS_METHOD begin
            convert(ComplexType1, variable_2)
        end
    end

    @testset "complex types - ComplexType2 and ComplexTypeNoDefault" begin
        variable_1 = ComplexType2("aa", 5.5, 5, 7)
        variable_2 = ComplexTypeNoDefault("aa", 5.5, 5, 7, "bb", 11.1)

        # Incompatible conversions
        @test_throws EXPECTED_THROWS_CANNOT_CONVERT(ComplexType2, ComplexTypeNoDefault) begin
            convert(ComplexTypeNoDefault, variable_1)
        end
        @test_throws EXPECTED_THROWS_CANNOT_CONVERT(ComplexTypeNoDefault, ComplexType2) begin
            convert(ComplexType2, variable_2)
        end
    end

    @testset "complex types - ComplexType2 and ComplexTypeDefault" begin
        variable_1 = ComplexType2("aa", 5.5, 5, 7)
        variable_2 = ComplexTypeDefault(field_string = "aa", field_float = 5.5, field_integer = 5, field_unsigned = 7)

        @test begin
            convert_1 = convert(ComplexTypeDefault, variable_1)
            convert_1 isa ComplexTypeDefault
        end

        # Incompatible conversion
        @test_throws EXPECTED_THROWS_CANNOT_CONVERT(ComplexTypeDefault, ComplexType2) begin
            convert(ComplexType2, variable_2)
        end
    end

    @testset "complex types - ComplexType2 and ComplexTypeDifferentDefault" begin
        variable_1 = ComplexType2("aa", 5.5, 5, 7)
        variable_2 =
            ComplexTypeDifferentDefault(field_string = "aa", field_float = 5.5, field_integer = 5, field_unsigned = 7)

        @test begin
            convert_1 = convert(ComplexTypeDifferentDefault, variable_1)
            convert_1 isa ComplexTypeDifferentDefault
        end

        # Incompatible conversion
        @test_throws EXPECTED_THROWS_CANNOT_CONVERT(ComplexTypeDifferentDefault, ComplexType2) begin
            convert(ComplexType2, variable_2)
        end
    end

    @testset "complex types - ComplexType2 and ComplexTypeAllString" begin
        variable_1 = ComplexType2("aa", 5.5, 5, 7)
        variable_2 = ComplexTypeAllString("aa", "5.5", "5", "7")

        # Incompatible conversions
        @test_throws EXPECTED_THROWS_METHOD begin
            convert(ComplexTypeAllString, variable_1)
        end
        @test_throws EXPECTED_THROWS_METHOD begin
            convert(ComplexType2, variable_2)
        end
    end

    @testset "complex types - ComplexTypeNoDefault and ComplexTypeDefault" begin
        variable_1 = ComplexTypeNoDefault("aa", 5.5, 5, 7, "bb", 11.1)
        variable_2 = ComplexTypeDefault(field_string = "aa", field_float = 5.5, field_integer = 5, field_unsigned = 7)

        @test begin
            convert_1 = convert(ComplexTypeDefault, variable_1)
            convert_1 isa ComplexTypeDefault
        end
        @test begin
            convert_2 = convert(ComplexTypeNoDefault, variable_2)
            convert_2 isa ComplexTypeNoDefault
        end
    end

    @testset "complex types - ComplexTypeNoDefault and ComplexTypeDifferentDefault" begin
        variable_1 = ComplexTypeNoDefault("aa", 5.5, 5, 7, "bb", 11.1)
        variable_2 =
            ComplexTypeDifferentDefault(field_string = "aa", field_float = 5.5, field_integer = 5, field_unsigned = 7)

        @test begin
            convert_1 = convert(ComplexTypeDifferentDefault, variable_1)
            convert_1 isa ComplexTypeDifferentDefault
        end
        @test begin
            convert_2 = convert(ComplexTypeNoDefault, variable_2)
            convert_2 isa ComplexTypeNoDefault
        end
    end

    @testset "complex types - ComplexTypeNoDefault and ComplexTypeAllString" begin
        variable_1 = ComplexTypeNoDefault("aa", 5.5, 5, 7, "bb", 11.1)
        variable_2 = ComplexTypeAllString("aa", "5.5", "5", "7")

        # Incompatible conversions
        @test_throws EXPECTED_THROWS_CANNOT_CONVERT(ComplexTypeNoDefault, ComplexTypeAllString) begin
            convert(ComplexTypeAllString, variable_1)
        end
        @test_throws EXPECTED_THROWS_CANNOT_CONVERT(ComplexTypeAllString, ComplexTypeNoDefault) begin
            convert(ComplexTypeNoDefault, variable_2)
        end
    end

    @testset "complex types - ComplexTypeDefault and ComplexTypeDifferentDefault" begin
        variable_1 = ComplexTypeDefault("aa", 5.5, 5, 7, "bb", 11.1)
        variable_2 =
            ComplexTypeDifferentDefault(field_string = "aa", field_float = 5.5, field_integer = 5, field_unsigned = 7)

        @test begin
            convert_1 = convert(ComplexTypeDifferentDefault, variable_1)
            convert_1 isa ComplexTypeDifferentDefault
        end
        @test begin
            convert_2 = convert(ComplexTypeDefault, variable_2)
            convert_2 isa ComplexTypeDefault
        end
    end

    @testset "complex types - ComplexTypeDefault and ComplexTypeAllString" begin
        variable_1 = ComplexTypeDefault("aa", 5.5, 5, 7, "bb", 11.1)
        variable_2 = ComplexTypeAllString("aa", "5.5", "5", "7")

        # Incompatible conversions
        @test_throws EXPECTED_THROWS_CANNOT_CONVERT(ComplexTypeDefault, ComplexTypeAllString) begin
            convert(ComplexTypeAllString, variable_1)
        end
        @test_throws EXPECTED_THROWS_METHOD begin
            convert(ComplexTypeDefault, variable_2)
        end
    end

    @testset "complex types - ComplexTypeDifferentDefault and ComplexTypeAllString" begin
        variable_1 =
            ComplexTypeDifferentDefault(field_string = "aa", field_float = 5.5, field_integer = 5, field_unsigned = 7)
        variable_2 = ComplexTypeAllString("aa", "5.5", "5", "7")

        # Incompatible conversions
        @test_throws EXPECTED_THROWS_CANNOT_CONVERT(ComplexTypeDifferentDefault, ComplexTypeAllString) begin
            convert(ComplexTypeAllString, variable_1)
        end
        @test_throws EXPECTED_THROWS_METHOD begin
            convert(ComplexTypeDifferentDefault, variable_2)
        end
    end
end

include("restricted_unsigned_types.jl")

const small_unsigned_value = min_unsigned_value - 1
const medium_unsigned_value = min_unsigned_value + 1
const large_unsigned_value = max_unsigned_value + 1
const few_digits_unsigned_value = parse(UInt64, "5"^(max_unsigned_digits - 1))
const many_digits_unsigned_value = parse(UInt64, "5"^(2 * max_unsigned_digits))

const unsigned_types_values = [
    [
        MaxInclusiveRestrictedUnsigned,
        [small_unsigned_value, medium_unsigned_value, min_unsigned_value, max_unsigned_value],
        [large_unsigned_value],
    ],
    [
        MaxExclusiveRestrictedUnsigned,
        [small_unsigned_value, medium_unsigned_value, min_unsigned_value],
        [large_unsigned_value, max_unsigned_value],
    ],
    [
        MinInclusiveRestrictedUnsigned,
        [medium_unsigned_value, large_unsigned_value, max_unsigned_value, min_unsigned_value],
        [small_unsigned_value],
    ],
    [
        MinExclusiveRestrictedUnsigned,
        [medium_unsigned_value, large_unsigned_value, max_unsigned_value],
        [small_unsigned_value, min_unsigned_value],
    ],
    [
        MinMaxInclusiveRestrictedUnsigned,
        [medium_unsigned_value, min_unsigned_value, max_unsigned_value],
        [small_unsigned_value, large_unsigned_value],
    ],
    [
        MinMaxExclusiveRestrictedUnsigned,
        [medium_unsigned_value],
        [small_unsigned_value, large_unsigned_value, min_unsigned_value, max_unsigned_value],
    ],
    [DigitsRestrictedUnsigned, [few_digits_unsigned_value], [many_digits_unsigned_value]],
]

@testset "Restricted XSDUnsigned $test_type" for (test_type, valid_values, invalid_values) in unsigned_types_values
    @testset "Restricted XSDUnsigned $test_type - valid value: $valid_value" for valid_value in valid_values
        @testset "One positional, valid" begin
            @test test_type(valid_value) isa test_type
        end
        @testset "One positional, valid, no check" begin
            @test test_type(valid_value, __validated = false) isa test_type
        end
        @testset "Two positional, valid" begin
            @test test_type(valid_value, test_xml_attributes) isa test_type
        end
        @testset "Two positional, valid, no check" begin
            @test test_type(valid_value, test_xml_attributes, false) isa test_type
        end

        @testset "One keyword, valid" begin
            @test test_type(value = valid_value) isa test_type
        end
        @testset "One keyword, valid, no check" begin
            @test test_type(value = valid_value, __validated = false) isa test_type
        end
        @testset "Two keyword, valid" begin
            @test test_type(value = valid_value, __xml_attributes = test_xml_attributes) isa test_type
        end
        @testset "Two keyword, valid, no check" begin
            @test test_type(value = valid_value, __xml_attributes = test_xml_attributes, __validated = false) isa
                  test_type
        end
    end

    @testset "Restricted XSDUnsigned $test_type - invalid value: $invalid_value" for invalid_value in invalid_values
        @testset "One positional, invalid" begin
            @test_throws AbstractXsdTypes.XSDValueRestrictionViolationError test_type(invalid_value) isa test_type
        end
        @testset "One positional, invalid, no check" begin
            @test test_type(invalid_value, __validated = false) isa test_type
        end
        @testset "Two positional, invalid" begin
            @test_throws AbstractXsdTypes.XSDValueRestrictionViolationError test_type(
                invalid_value,
                test_xml_attributes,
            ) isa test_type
        end
        @testset "Two positional, invalid, no check" begin
            @test test_type(invalid_value, test_xml_attributes, false) isa test_type
        end

        @testset "One keyword, invalid" begin
            @test_throws AbstractXsdTypes.XSDValueRestrictionViolationError test_type(value = invalid_value) isa
                                                                            test_type
        end
        @testset "One keyword, invalid, no check" begin
            @test test_type(value = invalid_value, __validated = false) isa test_type
        end
        @testset "Two keyword, invalid" begin
            @test_throws AbstractXsdTypes.XSDValueRestrictionViolationError test_type(
                value = invalid_value,
                __xml_attributes = test_xml_attributes,
            ) isa test_type
        end
        @testset "Two keyword, invalid, no check" begin
            @test test_type(value = invalid_value, __xml_attributes = test_xml_attributes, __validated = false) isa
                  test_type
        end
    end
end

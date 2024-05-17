include("restricted_signed_types.jl")

const base_signed_value = 3
const large_positive_signed_value = base_signed_value * positive_signed_value
const large_negative_signed_value = base_signed_value * negative_signed_value
const few_digits_signed_value = parse(Int64, "5"^(max_signed_digits - 1))
const many_digits_signed_value = parse(Int64, "5"^(2 * max_signed_digits))

const signed_types_values = [
    [
        MaxInclusiveRestrictedSigned,
        [base_signed_value, large_negative_signed_value, positive_signed_value, negative_signed_value],
        [large_positive_signed_value],
    ],
    [
        MaxExclusiveRestrictedSigned,
        [base_signed_value, large_negative_signed_value, negative_signed_value],
        [large_positive_signed_value, positive_signed_value],
    ],
    [
        MinInclusiveRestrictedSigned,
        [base_signed_value, large_positive_signed_value, positive_signed_value, negative_signed_value],
        [large_negative_signed_value],
    ],
    [
        MinExclusiveRestrictedSigned,
        [base_signed_value, large_positive_signed_value, positive_signed_value],
        [large_negative_signed_value, negative_signed_value],
    ],
    [
        MinExclusiveRestrictedSigned,
        [base_signed_value, large_positive_signed_value, positive_signed_value],
        [large_negative_signed_value, negative_signed_value],
    ],
    [DigitsRestrictedSigned, [few_digits_signed_value], [many_digits_signed_value]],
]

@testset "Restricted XSDSigned $test_type" for (test_type, valid_values, invalid_values) in signed_types_values
    @testset "Restricted XSDSigned $test_type - valid value: $valid_value" for valid_value in valid_values
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

    @testset "Restricted XSDSigned $test_type - invalid value: $invalid_value" for invalid_value in invalid_values
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

include("restricted_float_types.jl")

const base_float_value = 3.0
const large_positive_float_value = base_float_value * positive_float_value
const large_negative_float_value = base_float_value * negative_float_value
const few_total_digits_float_value = parse(Float64, "5"^(max_float_digits - 1))
const many_total_digits_float_value = parse(Float64, "5"^(2 * max_float_digits))
const few_fraction_digits_float_value = parse(Float64, "5"^2 * "." * "6"^(max_float_digits - 3))
const many_fraction_digits_float_value = parse(Float64, "5"^2 * "." * "6"^(2 * max_float_digits))
const zero_fraction_digits_float_value = Float64(20230510)

const float_types_values = [
    [
        MaxInclusiveRestrictedFloat,
        [base_float_value, large_negative_float_value, positive_float_value, negative_float_value],
        [large_positive_float_value],
    ],
    [
        MaxExclusiveRestrictedFloat,
        [base_float_value, large_negative_float_value, negative_float_value],
        [large_positive_float_value, positive_float_value],
    ],
    [
        MinInclusiveRestrictedFloat,
        [base_float_value, large_positive_float_value, positive_float_value, negative_float_value],
        [large_negative_float_value],
    ],
    [
        MinExclusiveRestrictedFloat,
        [base_float_value, large_positive_float_value, positive_float_value],
        [large_negative_float_value, negative_float_value],
    ],
    [
        MinExclusiveRestrictedFloat,
        [base_float_value, large_positive_float_value, positive_float_value],
        [large_negative_float_value, negative_float_value],
    ],
    [
        TotalDigitsRestrictedFloat,
        [few_total_digits_float_value, few_fraction_digits_float_value],
        [many_total_digits_float_value, many_fraction_digits_float_value],
    ],
    [
        FractionDigitsRestrictedFloat,
        [few_fraction_digits_float_value, few_total_digits_float_value, zero_fraction_digits_float_value],
        [many_fraction_digits_float_value],
    ],
    [
        ZeroFractionDigitsRestrictedFloat,
        [zero_fraction_digits_float_value, few_total_digits_float_value],
        [few_fraction_digits_float_value, many_fraction_digits_float_value],
    ],
]

@testset "Restricted XSDFloats $test_type" for (test_type, valid_values, invalid_values) in float_types_values
    @testset "Restricted XSDFloats $test_type - valid value: $valid_value" for valid_value in valid_values
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

    @testset "Restricted XSDFloats $test_type - invalid value: $invalid_value" for invalid_value in invalid_values
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

include("restricted_string_types.jl")

const test_string_short = "a"
const test_string_long_1 = test_string_short^(min_string_length + 1)
const test_string_long_2 = test_string_short^(max_string_length + 1)
const test_string_numbers = "5677"
const test_string_numbers_2 = "8811"
const test_string_numbers_short = "56"
const test_string_numbers_long_1 = test_string_numbers_short^Int(floor(min_string_length / 2) + 1)
const test_string_numbers_long_2 = test_string_numbers_short^Int(ceil(max_string_length / 2) + 1)

const string_types_values = [
    [
        MinLengthRestrictedString,
        [test_string_long_1, test_string_long_2, test_string_numbers_long_1, test_string_numbers_long_2],
        [test_string_short, test_string_short^(min_string_length - 1)],
    ],
    [
        MaxLengthRestrictedString,
        [test_string_short^max_string_length],
        [test_string_long_2, test_string_long_2^2, test_string_numbers_long_2],
    ],
    [
        FixedLengthRestrictedString,
        [test_string_long_2[1:max_string_length], test_string_numbers_long_2[1:max_string_length]],
        [
            test_string_short,
            test_string_long_1,
            test_string_long_2,
            test_string_numbers,
            test_string_numbers_2,
            test_string_numbers_short,
            test_string_numbers_long_1,
        ],
    ],
    [
        PatternRestrictedString,
        [test_string_numbers, test_string_numbers_2],
        [test_string_short, test_string_long_1, test_string_long_2, test_string_numbers_short],
    ],
    [
        PatternMinMaxLengthRestrictedString,
        [test_string_numbers_long_1],
        [test_string_long_1, test_string_short, test_string_long_2, test_string_numbers_long_2],
    ],
]

@testset "Restricted XSDstrings $test_type" for (test_type, valid_values, invalid_values) in string_types_values
    @testset "Restricted XSDstrings $test_type - valid value: $valid_value" for valid_value in valid_values
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

    @testset "Restricted XSDstrings $test_type - invalid value: $invalid_value" for invalid_value in invalid_values
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

include("mathematics_functions_types.jl")

const xsd_float_1 = XsdFloat1(rand(RNG, Float64))
const xsd_float_2 = XsdFloat2(rand(RNG, Float64))
const xsd_signed_1 = XsdSigned1(rand(RNG, Int64))
const xsd_signed_2 = XsdSigned2(rand(RNG, Int64))
const xsd_unsigned_1 = XsdUnSigned1(rand(RNG, UInt64))
const xsd_unsigned_2 = XsdUnSigned2(rand(RNG, UInt64))

const xsd_mathematics_test_values =
    [xsd_float_1, xsd_signed_1, xsd_unsigned_1, xsd_float_2, xsd_signed_2, xsd_unsigned_2]

const random_float = rand(RNG, Float64)
const random_signed = rand(RNG, Int64)
const random_unsigned = rand(RNG, UInt64)

const all_mathematics_test_values = vcat(xsd_mathematics_test_values, [random_float, random_signed, random_unsigned])
const all_mathematics_test_value_pairs = Iterators.product(all_mathematics_test_values, all_mathematics_test_values)

@testset "Mathematical functions" begin
    @testset "Mathematical functions - unary minus - $test_value" for test_value in xsd_mathematics_test_values
        @test begin
            -test_value
            true
        end
    end

    @testset "Mathematical functions - addition - $test_value_pair" for test_value_pair in
                                                                        all_mathematics_test_value_pairs
        @test begin
            first(test_value_pair) + last(test_value_pair)
            true
        end
    end

    @testset "Mathematical functions - subtraction - $test_value_pair" for test_value_pair in
                                                                           all_mathematics_test_value_pairs
        @test begin
            first(test_value_pair) - last(test_value_pair)
            true
        end
    end

    @testset "Mathematical functions - product - $test_value_pair" for test_value_pair in
                                                                       all_mathematics_test_value_pairs
        @test begin
            first(test_value_pair) * last(test_value_pair)
            true
        end
    end

    @testset "Mathematical functions - division - $test_value_pair" for test_value_pair in
                                                                        all_mathematics_test_value_pairs
        @test begin
            first(test_value_pair) / last(test_value_pair)
            true
        end
    end

    @testset "Mathematical functions - comparison - $test_value" for test_value in xsd_mathematics_test_values
        @testset "Mathematical functions - comparison - $test_value - <" begin
            @test !(test_value < test_value)
        end
        @testset "Mathematical functions - comparison - $test_value - ==" begin
            @test test_value == test_value
        end
        @testset "Mathematical functions - comparison - $test_value - >" begin
            @test !(test_value > test_value)
        end
    end

    @testset "Mathematical functions - comparison - $test_value_pair" for test_value_pair in
                                                                          all_mathematics_test_value_pairs
        @testset "Mathematical functions - comparison - $test_value_pair - <" begin
            @test begin
                first(test_value_pair) < last(test_value_pair)
                true
            end
        end
        @testset "Mathematical functions - comparison - $test_value_pair - ==" begin
            @test begin
                first(test_value_pair) == last(test_value_pair)
                true
            end
        end
        @testset "Mathematical functions - comparison - $test_value_pair - >" begin
            @test begin
                first(test_value_pair) > last(test_value_pair)
                true
            end
        end
    end

    @testset "Mathematical functions - sorting" begin
        @test begin
            sorted = sort(xsd_mathematics_test_values)
            issorted(sorted)
        end
    end
end

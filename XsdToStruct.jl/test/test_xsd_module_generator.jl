
# generic test cases
@testset "xsd reader - generic data" begin
    for test_file in get_test_files(generic_data_dir)
        @testset "xsd reader - generic data - $(basename(test_file))" begin
            base_name = basename(test_file)
            input_path = test_file * ".xsd"
            expected_output_dir = test_file

            output_path = xsd_to_struct_module(input_path, output_dir)
            @test compare_all_text_files(dirname(output_path), expected_output_dir)
        end
    end
end

# edge cases
@testset "xsd reader - edge cases" begin
    for test_file in get_test_files(edge_data_dir)
        @test_throws ErrorException xsd_to_struct_module(test_file * ".xsd", output_dir)
    end
end

# specific examples
@testset "xsd reader - specific examples" begin
    for test_file in get_test_files(specific_data_dir)
        base_name = basename(test_file)
        input_path = test_file * ".xsd"
        expected_output_dir = test_file

        output_path = xsd_to_struct_module(input_path, output_dir)
        @test compare_all_text_files(dirname(output_path), expected_output_dir)
    end
end

# generic test cases with dict
@testset "xsd reader - generic data - dict" begin
    tmp_output_dir = output_dir * "_tmp"
    xsd_locations = Dict{String,String}()

    for test_file in get_test_files(generic_data_dir)
        xsd_locations[basename(test_file)] = generic_data_dir
    end

    generate_modules(xsd_locations, tmp_output_dir)

    for file_name in keys(xsd_locations)
        @test isfile(joinpath(tmp_output_dir, file_name, file_name * ".jl"))
    end

    rm(tmp_output_dir, recursive = true)
end

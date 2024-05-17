
# input data directory
generic_data_dir = joinpath(pkgdir(XmlStructWriter), "test", "test_data", "generic_cases")

output_dir = joinpath(pkgdir(XmlStructWriter), "test", "test_output")
if isdir(output_dir)
    # cleanup
    rm(output_dir, recursive = true)
end

# generate modules for loading
generate_modules(generic_data_dir)

# get files for testing
generic_test_files = get_test_files(generic_data_dir)

# generic test cases
@testset "writing - generic cases - $(basename(module_dir))" for (module_dir, xml_files) in generic_test_files
    if isempty(xml_files)
        module_ref = nothing
    else
        module_ref = XmlStructLoader.import_module_from_xml(xml_files |> first |> first, module_dir)
    end

    @testset "writing - generic cases - $(basename(module_dir)) - $(basename(xml_path))" for (
        xml_path,
        expected_path,
    ) in xml_files
        output_path = joinpath(output_dir, basename(xml_path))
        @test begin
            xml_loaded = load(xml_path, module_ref)
            write_xml(xml_loaded, output_path)
            compare_xml_files(expected_path, output_path)
        end
    end
end

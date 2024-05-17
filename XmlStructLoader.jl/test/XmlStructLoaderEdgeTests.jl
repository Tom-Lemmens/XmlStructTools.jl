
# input data
edge_data_dir = abspath(joinpath(pkgdir(XmlStructLoader), "test", "test_data", "edge_cases"))
edge_test_files = get_test_files(edge_data_dir)

# generate modules for testing
generate_modules(edge_data_dir)

# run tests
@testset "Edge tests load" begin
    @testset "Edge tests load - $(basename(module_dir))" for (module_dir, xml_files) in edge_test_files
        @info "Running edge tests load - $(basename(module_dir))"
        @testset "Edge tests load - $(basename(module_dir)) - $(basename(xml_path))" for xml_path in xml_files
            @info "Running edge tests load - $(basename(module_dir)) - $(basename(xml_path))"

            # with directory
            @test begin
                load(xml_path, module_dir)
                true
            end

            # with loaded module
            @test begin
                module_ref = XmlStructLoader.import_module_from_xml(xml_path, module_dir)
                load(xml_path, module_ref)
                true
            end
        end
    end
end

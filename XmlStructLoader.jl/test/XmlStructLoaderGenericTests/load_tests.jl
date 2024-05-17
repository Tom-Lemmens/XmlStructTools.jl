@testset "Generic load test" begin
    @testset "Generic load test - $(basename(module_dir))" for (module_dir, xml_files) in generic_test_files
        @info "Running generic load test - $(basename(module_dir))"
        @testset "Generic load test - $(basename(module_dir)) - $(basename(xml_path))" for xml_path in xml_files
            @info "Running generic load test - $(basename(module_dir)) - $(basename(xml_path))"

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

            # with io stream
            @test begin
                open(xml_path) do io
                    return load(io, module_dir)
                end
                true
            end

            # with io stream and loaded module
            @test begin
                module_ref = XmlStructLoader.import_module_from_xml(xml_path, module_dir)
                open(xml_path) do io
                    return load(io, module_ref)
                end
                true
            end
        end
    end
end

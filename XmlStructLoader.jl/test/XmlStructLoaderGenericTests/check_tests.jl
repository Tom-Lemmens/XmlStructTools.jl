@testset "Generic check test" begin

    # tests for simple_types
    xsd_name = "simple_types"
    module_dir = joinpath(generic_data_dir, xsd_name)
    @testset "Generic check test - $(basename(module_dir))" begin
        @info "Running generic check test - $(basename(module_dir))"

        # first xml
        xml_name = xsd_name * "_1"
        xml_path = joinpath(generic_data_dir, xml_name * ".xml")
        @testset "Generic check test - $(basename(module_dir)) - $(basename(xml_path))" begin
            @info "Running generic check test - $(basename(module_dir)) - $(basename(xml_path))"

            xml = maybe_load(xml_path, module_dir)
            @info "Loaded xml: $(!isnothing(xml))"
            @test isnothing(xml) ? false : xml.TestElement2.TestElement11 == "DEFA"
            @test isnothing(xml) ? false : xml.TestElement2.TestElement12 == ""
        end

        # second xml
        xml_name = xsd_name * "_2"
        xml_path = joinpath(generic_data_dir, xml_name * ".xml")
        @testset "Generic check test - $(basename(module_dir)) - $(basename(xml_path))" begin
            @info "Running generic check test - $(basename(module_dir)) - $(basename(xml_path))"

            xml = maybe_load(xml_path, module_dir)
            @info "Loaded xml: $(!isnothing(xml))"
            @test isnothing(xml) ? false : xml.TestElement2.TestElement11 == "AAAA"
            @test isnothing(xml) ? false : xml.TestElement2.TestElement12 == ""
        end

        # third xml
        xml_name = xsd_name * "_3"
        xml_path = joinpath(generic_data_dir, xml_name * ".xml")
        @testset "Generic check test - $(basename(module_dir)) - $(basename(xml_path))" begin
            @info "Running generic check test - $(basename(module_dir)) - $(basename(xml_path))"

            xml = maybe_load(xml_path, module_dir)
            @info "Loaded xml: $(!isnothing(xml))"
            @test isnothing(xml) ? false : xml.TestElement2.TestElement11 == "AAAA"
            @test isnothing(xml) ? false : xml.TestElement2.TestElement12 == "BBBB"
        end
    end
end

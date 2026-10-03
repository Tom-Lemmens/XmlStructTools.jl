# `precompile_schema` exists to be called while a consumer's package precompiles. Outside
# precompilation it must be inert, and it must not turn a bad sample into a failed build - both of
# those are what makes it safe to put in someone else's module.

@testset "Precompile schema" begin
    list_module = joinpath(generic_data_dir, "list_content")
    list_xml = joinpath(generic_data_dir, "list_content.xml")

    @testset "Precompile schema - inert outside precompilation" begin
        module_ref = XmlStructLoader.import_module_from_xml(list_xml, list_module)
        sample = read(list_xml, String)
        @test isnothing(XmlStructLoader.precompile_schema(module_ref, sample))
    end

    @testset "Precompile schema - a module without a sample warns" begin
        module_ref = XmlStructLoader.import_module_from_xml(list_xml, list_module)
        @test_logs (:warn, r"carries no precompile sample") XmlStructLoader.precompile_schema(module_ref)
    end

    @testset "Precompile schema - an unloadable sample does not throw" begin
        module_ref = XmlStructLoader.import_module_from_xml(list_xml, list_module)
        # Well-formed XML that is not this schema: the workload must warn at most.
        @test isnothing(XmlStructLoader.precompile_schema(module_ref, "<nonsense/>"))
    end
end

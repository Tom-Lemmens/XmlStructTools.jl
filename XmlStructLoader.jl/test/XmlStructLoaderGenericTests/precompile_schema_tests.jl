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

    @testset "Precompile schema - an unloadable sample warns instead of failing" begin
        module_ref = XmlStructLoader.import_module_from_xml(list_xml, list_module)
        # The workload only runs while a package is precompiling, which a test is not; asking
        # PrecompileTools to run it anyway is what makes this exercise the guarded block rather
        # than the check that skips it.
        previous = XmlStructLoader.PrecompileTools.verbose[]
        XmlStructLoader.PrecompileTools.verbose[] = true
        try
            # Well-formed XML that is not this schema: a build must not fail over a bad sample.
            @test_logs (:warn, r"did not complete") match_mode = :any begin
                @test isnothing(XmlStructLoader.precompile_schema(module_ref, "<nonsense/>"))
            end
        finally
            XmlStructLoader.PrecompileTools.verbose[] = previous
        end
    end

    @testset "Precompile schema - a usable sample runs the workload" begin
        module_ref = XmlStructLoader.import_module_from_xml(list_xml, list_module)
        sample = read(list_xml, String)
        previous = XmlStructLoader.PrecompileTools.verbose[]
        XmlStructLoader.PrecompileTools.verbose[] = true
        try
            # No warning: the four load shapes the workload performs all succeed.
            @test_logs min_level = Logging.Warn XmlStructLoader.precompile_schema(module_ref, sample)
        finally
            XmlStructLoader.PrecompileTools.verbose[] = previous
        end
    end
end

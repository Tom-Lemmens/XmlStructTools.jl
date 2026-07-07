# Real-world stress fixture (see test_data/real_world/README.md): a genuine, unmodified ISO 20022
# schema, much larger and more interconnected than any of this repo's own synthetic fixtures.
# Checked via "does it generate with no warnings and does the result actually compile" rather than
# a byte-for-byte golden-text comparison (the generic/specific_cases convention) - a real-world
# fixture this size is meant to catch structural regressions (a type silently going missing again,
# a construct XsdToStruct.jl doesn't handle raising @warn instead of erroring), not to lock in
# exact generated-code formatting.
@testset "real world - pacs.008.001.09" begin
    real_world_dir = joinpath(generic_data_dir, "..", "real_world")
    xsd_path = joinpath(real_world_dir, "pacs.008.001.09.xsd")
    output_dir = mktempdir()

    warnings = Test.collect_test_logs() do
        xsd_to_struct_module(xsd_path, output_dir)
    end |> first
    @test isempty(filter(record -> record.level >= Logging.Warn, warnings))

    generated_path = joinpath(output_dir, "pacs_008_001_09", "pacs_008_001_09.jl")
    @test isfile(generated_path)

    mod = Base.include(Main, generated_path)
    # include() defines Document (and everything else) in a world newer than the one this
    # already-compiled testset function was called in - the same @invokelatest requirement fixed
    # elsewhere in this session's XmlStructLoader.jl work, here on the reader/codegen side instead.
    @test Base.invokelatest(isdefined, mod, :Document)
    @test Base.invokelatest(() -> mod.__meta.root_type == mod.Document)
end

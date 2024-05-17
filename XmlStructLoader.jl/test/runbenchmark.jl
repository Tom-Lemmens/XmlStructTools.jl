using BenchmarkTools
using XmlStructLoader

include("test_utilities.jl")

generic_data_dir = abspath(joinpath("test", "test_data", "generic_cases"))
generic_test_files = get_test_files(generic_data_dir)

open("results.txt", "w") do io
    println(io, "Benchmark results:")
    println(io)

    for test_files in generic_test_files
        println(io)

        module_dir = first(test_files)

        message = "Running benchmark for module: $(basename(module_dir))"
        @info message
        println(io, message)

        module_ref = XmlStructLoader.import_module_from_xml(last(test_files) |> first, module_dir)

        for xml_path in last(test_files)
            message = "Running benchmark for xml: $(basename(xml_path))"
            @info message
            println(io, message)

            benchmark = @benchmarkable test_load($xml_path, $module_ref) samples = 1000
            result = run(benchmark)
            println(io, result)
        end
    end
end

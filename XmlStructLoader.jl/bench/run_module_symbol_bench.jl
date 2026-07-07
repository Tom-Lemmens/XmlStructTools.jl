# Benchmark for Task #22: does swapping xml_module_utilities.jl's EzXML.StreamReader-based
# get_module_symbol() peek to a full pugixml parse regress load(path, module_path::AbstractString)?
#
# Measures three things per fixture:
#   1. get_module_symbol(io) alone (the peek itself)
#   2. load(path, module_path) end-to-end (peek + real full parse + construct)
#   3. load(path, module_ref) end-to-end (real full parse + construct, no peek at all) - the
#      floor this path can never beat, useful to see what fraction of (2) the peek actually costs
#
# julia --project=bench bench/run_module_symbol_bench.jl

using Chairmarks, JSON, XmlStructLoader
using Statistics: median, quantile

const HERE = @__DIR__
const ROOT = dirname(HERE)

function stats(b)
    s = Float64[x.time for x in b.samples]
    return (median = median(s), relsigma = (quantile(s, 0.75) - quantile(s, 0.25)) / 2 / median(s), n = length(s))
end

fixtures = [
    ("basic_types", joinpath(ROOT, "test", "test_data", "generic_cases", "basic_types.xml"), joinpath(ROOT, "test", "test_data", "generic_cases", "basic_types")),
    ("large_synthetic", joinpath(HERE, "fixtures", "large_synthetic.xml"), joinpath(HERE, "fixtures", "large_synthetic")),
]

out = Dict{String, Any}()
for (name, xml_path, module_dir) in fixtures
    module_ref = XmlStructLoader.import_module_from_xml(xml_path, module_dir)

    b_peek = @be XmlStructLoader.import_module_from_xml($xml_path, $module_dir) seconds = 2
    r_peek = stats(b_peek)

    b_by_path = @be XmlStructLoader.load($xml_path, $module_dir) seconds = 2
    r_by_path = stats(b_by_path)

    b_by_ref = @be XmlStructLoader.load($xml_path, $module_ref) seconds = 2
    r_by_ref = stats(b_by_ref)

    println("=== $name ===")
    println("  import_module_from_xml (peek):    median=$(round(r_peek.median * 1.0e6, digits = 2))us  (relsigma=$(round(100r_peek.relsigma, digits = 1))%)")
    println("  load(path, module_path):          median=$(round(r_by_path.median * 1.0e6, digits = 2))us  (relsigma=$(round(100r_by_path.relsigma, digits = 1))%)")
    println("  load(path, module_ref) [no peek]: median=$(round(r_by_ref.median * 1.0e6, digits = 2))us  (relsigma=$(round(100r_by_ref.relsigma, digits = 1))%)")
    println("  peek overhead vs no-peek floor:    $(round((r_by_path.median - r_by_ref.median) * 1.0e6, digits = 2))us ($(round(100 * (r_by_path.median - r_by_ref.median) / r_by_ref.median, digits = 1))% of the no-peek floor)")

    out[name] = Dict(
        "peek" => Dict("median_s" => r_peek.median, "relsigma" => r_peek.relsigma, "n" => r_peek.n),
        "load_by_path" => Dict("median_s" => r_by_path.median, "relsigma" => r_by_path.relsigma, "n" => r_by_path.n),
        "load_by_ref" => Dict("median_s" => r_by_ref.median, "relsigma" => r_by_ref.relsigma, "n" => r_by_ref.n),
    )
end

resdir = joinpath(HERE, "results")
mkpath(resdir)
resfile = joinpath(resdir, get(ENV, "BENCH_OUT", "module_symbol_baseline.json"))
open(resfile, "w") do io
    JSON.print(io, out, 2)
end
println("\nsaved raw medians -> ", resfile)

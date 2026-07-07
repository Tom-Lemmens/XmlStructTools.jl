# Baseline benchmark for XmlStructLoader.load — Phase 0 of the XML backend bake-off / perf plan
# (see ~/.claude/plans/dynamic-churning-abelson.md). Measures the CURRENT EzXML-backed loader; later
# phases add prototype backends and compare against the numbers saved here.
#
#   julia --project=bench bench/run_loader_bench.jl
#
# Methodology (matches this workspace's convention, see BlazingPorts.jl/CLAUDE.md): Chairmarks `@be`,
# compare the MEDIAN, report rel-sigma (half-IQR/median) so the spread is visible. Summary stats
# (median/n/relsigma) are saved to bench/results/*.json for later comparison. Cold-call time is
# captured separately (fresh `julia` process per fixture) since it's a distinct number from warm
# steady-state — relevant to the Phase 4 precompile decision and the Phase 1 `@nospecialize`
# decision, neither of which should be judged from a warm-only number.

using Chairmarks, JSON, XmlStructLoader
using Statistics: median, quantile

const HERE = @__DIR__
const ROOT = dirname(HERE)
include(joinpath(ROOT, "test", "test_utilities.jl"))  # get_test_files / get_matching_xml_files — no test-only deps

function stats(b)
    s = Float64[x.time for x in b.samples]
    (median = median(s), relsigma = (quantile(s, 0.75) - quantile(s, 0.25)) / 2 / median(s), n = length(s))
end

# fixture set: every generated-module dir under test_data/generic_cases + its paired .xml files
generic_data_dir = joinpath(ROOT, "test", "test_data", "generic_cases")
generic_test_files = get_test_files(generic_data_dir)

println("XmlStructLoader.load baseline (current EzXML backend) — warm median, Chairmarks @be.")

out = Dict{String,Any}()
for (module_dir, xml_files) in generic_test_files
    isempty(xml_files) && continue
    module_name = basename(module_dir)
    module_ref = XmlStructLoader.import_module_from_xml(first(xml_files), module_dir)

    for xml_path in xml_files
        xml_name = basename(xml_path)
        key = "$(module_name)/$(xml_name)"
        b = @be XmlStructLoader.load($xml_path, $module_ref) seconds = 2
        r = stats(b)
        println("  $(key):  median=$(round(r.median * 1e6, digits = 2))us  (n=$(r.n), relsigma=$(round(100r.relsigma, digits = 1))%)")
        out[key] = Dict("median_s" => r.median, "relsigma" => r.relsigma, "n" => r.n)
    end
end

# large synthetic fixture (fixtures/large_synthetic.{xsd,xml}) - regenerate the .xml with
# gen_large_fixture.jl [N] if a different record count is needed; the module is regenerated here.
large_xsd = joinpath(HERE, "fixtures", "large_synthetic.xsd")
large_xml = joinpath(HERE, "fixtures", "large_synthetic.xml")
if isfile(large_xsd) && isfile(large_xml)
    using XsdToStruct: xsd_to_struct_module
    xsd_to_struct_module(large_xsd, joinpath(HERE, "fixtures"))
    large_module_ref = XmlStructLoader.import_module_from_xml(large_xml, joinpath(HERE, "fixtures", "large_synthetic"))
    b = @be XmlStructLoader.load($large_xml, $large_module_ref) seconds = 5
    r = stats(b)
    n_entries = length(XmlStructLoader.load(large_xml, large_module_ref).Entry)
    println(
        "  large_synthetic ($(n_entries) entries):  median=$(round(r.median * 1e3, digits = 2))ms  (n=$(r.n), relsigma=$(round(100r.relsigma, digits = 1))%)",
    )
    out["large_synthetic"] = Dict("median_s" => r.median, "relsigma" => r.relsigma, "n" => r.n, "n_entries" => n_entries)
else
    @warn "large_synthetic fixture missing - run `julia --project=bench bench/gen_large_fixture.jl` first"
end

resdir = joinpath(HERE, "results")
mkpath(resdir)
resfile = joinpath(resdir, "loader_baseline.json")
open(resfile, "w") do io
    JSON.print(io, out, 2)
end
println("\nsaved raw medians -> ", resfile)

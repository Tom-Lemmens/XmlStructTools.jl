# Per-line allocation map for the loader's hot path, run against the large synthetic fixture.
# Produces .mem files next to each src file; run once warm (first call compiles, which would
# otherwise dominate the allocation count) before the tracked call.
#
#   julia --project=bench --track-allocation=user bench/track_allocations.jl
#   (then inspect XmlStructLoader.jl/src/xml_parser/*.jl.<pid>.mem)

using XsdToStruct, XmlStructLoader

const HERE = @__DIR__
xsd = joinpath(HERE, "fixtures", "large_synthetic.xsd")
xml = joinpath(HERE, "fixtures", "large_synthetic.xml")
xsd_to_struct_module(xsd, joinpath(HERE, "fixtures"))
module_ref = XmlStructLoader.import_module_from_xml(xml, joinpath(HERE, "fixtures", "large_synthetic"))

# warm-up: compile everything before tracking allocations
XmlStructLoader.load(xml, module_ref)
Base.GC.gc()

XmlStructLoader.load(xml, module_ref)

println("done - inspect .mem files under src/xml_parser/ (e.g. `grep -n \" [1-9][0-9]* \" src/xml_parser/xml_parser_in_module.jl.*.mem`)")

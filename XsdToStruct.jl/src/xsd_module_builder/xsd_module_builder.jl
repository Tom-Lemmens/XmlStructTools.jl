
const ABSTRACT_TYPE_PACKAGE = "AbstractXsdTypes"

include("xsd_module_builder_common.jl")
include("xsd_module_builder_top.jl")
include("xsd_module_builder_struct.jl")
include("xsd_module_builder_checks.jl")

# TODO: potential idea for running without writing to new file: use io = IOBuffer() and afterwards
# module_string = String(take!(io))) and then eval(Meta.parse(module_string))
function write_module(
    xsd_tree::SchemaTreeNode,
    module_file_name::AbstractString,
    output_dir::AbstractString,
    xsd_filename::AbstractString,
)::Nothing
    full_output_dir = joinpath(output_dir, module_file_name)
    output_top_module_path = joinpath(full_output_dir, module_file_name * ".jl")
    output_struct_module_path = joinpath(full_output_dir, module_file_name * "_struct" * ".jl")

    # ensure output dir exists
    if !isdir(full_output_dir)
        mkpath(full_output_dir)
    end

    open(output_top_module_path, "w") do io_top
        open(output_struct_module_path, "w") do io_struct
            xsd_module_builder = XSDStructModuleBuilderType(
                indent_string = "    ",
                xsd_tree = xsd_tree,
                io_top = io_top,
                io_struct = io_struct,
                xsd_filename = xsd_filename,
            )
            write_top_module_to_io(xsd_module_builder)
            return write_struct_module_to_io(xsd_module_builder)
        end
    end

    return nothing
end

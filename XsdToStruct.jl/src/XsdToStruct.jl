module XsdToStruct

using TOML
using LightXML
using Dates
using Downloads: download

const XsdToStruct_VERSION = let
    project = joinpath(pkgdir(XsdToStruct), "Project.toml")
    version = TOML.parsefile(project)["version"]
    VersionNumber(version)
end

include(joinpath("xsd_field_data", "xsd_field_data.jl"))
include(joinpath("xsd_tree", "xsd_tree.jl"))
include(joinpath("xsd_reader", "xsd_reader.jl"))
include(joinpath("xsd_module_builder", "xsd_module_builder.jl"))

export xsd_to_struct_module, generate_modules

"""
    xsd_to_struct_module(xsd_path::AbstractString, output_dir::AbstractString)::String

Generate Julia module corresponding to the given xsd file. The resulting Julia module will be placed in the given
`output_dir`. The module generated will have the same name as the xsd namespace defined in the given xsd file.
The path to the file with the generated code is given as a return value. The file generated will have the approximately
the same name as the given xsd file but with a ".jl" extension instead of ".xsd".
To use the generated module include the generated file that is returned by this function, and then use or import the
module.

# Examples
```julia-repl
julia> using XsdToStruct
julia> xsd_to_struct_module(joinpath("path", "to", "file.xsd"), joinpath("output", "dir"))
julia> include(joinpath("output", "dir", "file", "file.jl"))
julia> using file_xsd_namespace
```
or
```julia-repl
julia> using XsdToStruct
julia> xsd_to_struct_module(joinpath("path", "to", "file.xsd"), joinpath("output", "dir"))
julia> include(joinpath("output", "dir", "file", "file.jl"))
julia> import file_xsd_namespace
```
"""
function xsd_to_struct_module(xsd_path::AbstractString, output_dir::AbstractString)::String
    xsd_tree = read_xsd(xsd_path)

    process_xsd_tree!(xsd_tree)

    module_file_name = xsd_path |> basename |> splitext |> first
    module_file_name = replace(module_file_name, forbidden_characters_regex => "_")

    write_module(xsd_tree, module_file_name, output_dir, basename(xsd_path))

    return joinpath(output_dir, module_file_name, module_file_name * ".jl")
end

const forbidden_characters_regex = r"[^0-9a-zA-Z_-]+"

"""
    xsd_to_struct_module(xsd_path::AbstractString)::String

Generate Julia module corresponding to the given xsd file.
The resulting Julia module will be placed in the same directory as the given xsd file.
The path to the file with the generated code is given as a return value.

# Examples
```julia-repl
julia> using XsdToStruct
julia> xsd_to_struct_module(joinpath("path", "to", "file.xsd"))
julia> include(joinpath("path", "to", "file", "file.jl"))
julia> using file_xsd_namespace
```
or
```julia-repl
julia> using XsdToStruct
julia> xsd_to_struct_module(joinpath("path", "to", "file.xsd"))
julia> include(joinpath("path", "to", "file", "file.jl"))
julia> import file_xsd_namespace
```
"""
xsd_to_struct_module(xsd_path::AbstractString)::String = xsd_to_struct_module(xsd_path, dirname(xsd_path))

"""
    generate_modules(xsd_locations::Dict{AbstractString, AbstractString}, xsd_modules_path::AbstractString)::Nothing

Generate modules from the given locations. The `xsd_locations` should be a dict which maps xsd names to their locations.
The location can either be a path to a file, or a directory where the xsd file is located, or a URL where the xsd file
can downloaded from. The generated modules are placed into the given `xsd_modules_path`. It is recomended for any
packages that use generated modules to use this function in a build script to generate up to date modules on the fly.

# Examples
Let's assume we have a folder "xsd_files" which contains the xsd files: "file_1.xsd", "file_2.xsd", and "file_3.xsd",
and we also have a file located at a URL.
We can then generate modules for them and place these modules into the folder "xsd_modules" as follows:
```julia-repl
julia> using XsdToStruct
julia> xsd_locations = Dict(
    "local_file_1" => joinpath("path", "to", "xsd_files", "file_1.xsd"),
    "local_file_2" => joinpath("path", "to", "xsd_files"),
    "local_file_3" => joinpath("path", "to", "xsd_files"),
    "remote_file" => "https://url.to.last/xsd/file"
)
julia> xsd_modules_path = joinpath("output", "path", "for", "xsd", "modules")
julia> generate_modules(xsd_locations, xsd_modules_path)
```
"""
function generate_modules(
    xsd_locations::Dict{<:AbstractString,<:AbstractString},
    xsd_modules_path::AbstractString,
)::Nothing
    @info "Getting xsds and generating corresponding Julia modules."

    temp_download_dir = mktempdir()

    for (xsd_name, xsd_location) in xsd_locations
        if isfile(xsd_location)
            xsd_file_path = xsd_location
        elseif isdir(xsd_location)
            xsd_file_path = joinpath(xsd_location, xsd_name * ".xsd")
        else
            # assumption that if location is a not local file or directory the location is a download URL
            @info "Downloading xsd from $xsd_location"
            xsd_file_path = joinpath(temp_download_dir, xsd_name * ".xsd")
            download(xsd_location, xsd_file_path)
        end

        @info "Generating $xsd_name"
        xsd_to_struct_module(xsd_file_path, xsd_modules_path)
    end

    return nothing
end

end

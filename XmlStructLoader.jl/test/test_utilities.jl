
basename_startswith(file_path::AbstractString, start_string::AbstractString) =
    startswith(basename(file_path), start_string)

get_matching_xml_files(module_folder_path::AbstractString) = [
    file_path_i for file_path_i in readdir(dirname(module_folder_path); join = true) if
    endswith(file_path_i, ".xml") && basename_startswith(file_path_i, basename(module_folder_path))
]

get_base_name_without_extension(file_path::AbstractString) = join(split(basename(file_path), ".")[1:(end - 1)], ".")

function get_test_files(data_dir)
    return [
        (file_path, get_matching_xml_files(file_path)) for
        file_path in readdir(data_dir; join = true) if isdir(file_path)
    ]
end

function get_xsd_files(directory::AbstractString)::Vector{String}
    return [file_path for file_path in readdir(directory; join = true) if splitext(file_path) |> last == ".xsd"]
end

"""
    generate_modules(directory::AbstractString)::Nothing

Function to generate Julia modules for all xsd files found in the given directory.
"""
function generate_modules(directory::AbstractString)::Nothing
    @info "generating Julia modules for xsd files found in directory $directory"
    for xsd_file in get_xsd_files(directory)
        xsd_to_struct_module(xsd_file)
    end
    return nothing
end

"""
    maybe_load(xml_path::AbstractString, module_path::AbstractString)

Handles potentially failing loads. If load is successful the loaded xml is returned otherwise `nothing` is returned.
"""
function maybe_load(xml_path::AbstractString, module_path::AbstractString)
    local xml
    try
        xml = load(xml_path, module_path)
    catch
        xml = nothing
    end
    return xml
end

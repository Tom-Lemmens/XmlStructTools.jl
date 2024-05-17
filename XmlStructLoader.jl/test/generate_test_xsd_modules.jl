
# Utility script to generate all the xsd struct modules needed for running the tests.
# It is advised to run this after every update of XsdToStruct.
# Run this scrip in the test environment.

using XsdToStruct

data_directory = abspath(joinpath(@__DIR__, "test_data"))

get_xsd_files(directory::AbstractString)::Vector{String} =
    [file_path for file_path in readdir(directory; join = true) if splitext(file_path) |> last == ".xsd"]

function generate_modules(directory::AbstractString)::Nothing
    for xsd_file in get_xsd_files(directory)
        xsd_to_struct_module(xsd_file)
    end
    return nothing
end

# For all data subdirectories generate modules for all xsds
sub_directories = [path for path in readdir(data_directory; join = true) if isdir(path)]
for sub_dir in sub_directories
    @info "Generating module for $(basename(sub_dir))"
    generate_modules(sub_dir)
end

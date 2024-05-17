
get_xsd_files(directory::AbstractString)::Vector{String} =
    [file_path for file_path in readdir(directory; join = true) if splitext(file_path) |> last == ".xsd"]

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

basename_startswith(file_path::AbstractString, start_string::AbstractString) =
    startswith(basename(file_path), start_string)

get_matching_xml_files(module_folder_path::AbstractString) = [
    file_path_i for file_path_i in readdir(dirname(module_folder_path); join = true) if (
        endswith(file_path_i, ".xml") &&
        basename_startswith(file_path_i, basename(module_folder_path)) &&
        !occursin("_expected", basename(file_path_i))
    )
]

get_matching_expected_files(module_folder_path::AbstractString) = [
    file_path_i for file_path_i in readdir(dirname(module_folder_path); join = true) if (
        endswith(file_path_i, ".xml") &&
        basename_startswith(file_path_i, basename(module_folder_path)) &&
        occursin("_expected", basename(file_path_i))
    )
]

get_base_name_without_extension(file_path::AbstractString) = join(split(basename(file_path), ".")[1:(end - 1)], ".")

get_test_files(data_dir) = [
    (file_path, zip(get_matching_xml_files(file_path), get_matching_expected_files(file_path))) for
    file_path in readdir(data_dir; join = true) if isdir(file_path)
]

function compare_xml_files(file_path_1::AbstractString, file_path_2::AbstractString)::Bool
    xml_doc_1 = parse_file(file_path_1)
    root_1 = root(xml_doc_1)

    xml_doc_2 = parse_file(file_path_2)
    root_2 = root(xml_doc_2)

    return compare_xml_elements(root_1, root_2)
end

function compare_xml_elements(element_1::XMLElement, element_2::XMLElement)::Bool
    if has_children(element_1)
        # compare all children
        child_iterator_1 = collect(child_elements(element_1))
        n_children_1 = length(child_iterator_1)
        child_iterator_2 = collect(child_elements(element_2))
        n_children_2 = length(child_iterator_2)

        if n_children_1 != n_children_2
            if n_children_1 < n_children_2
                @info "Amount of children of $(name(element_1)) are different, first file has less children"
                return false
            else
                @info "Amount of children of $(name(element_1)) are different, second file has less children"
                return false
            end
        end

        for (child_1, child_2) in zip(child_iterator_1, child_iterator_2)
            if !compare_xml_elements(child_1, child_2)
                @info "Children of $(name(element_1)) are different"
                return false
            end
        end
    else
        # compare content
        if content(element_1) != content(element_2)
            @info "Content of $(name(element_1)) is different"
            return false
        end
    end

    # compare all attributes
    attributes_1 = attributes_dict(element_1)
    attributes_2 = attributes_dict(element_2)
    if attributes_1 != attributes_2
        @info "Attributes of $(name(element_1)) are different"
        return false
    end

    # everything is equal
    return true
end

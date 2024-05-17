
get_test_files(data_dir)::Vector{String} =
    [chop(file_path, tail = 4) for file_path in readdir(data_dir; join = true) if endswith(file_path, ".xsd")]

compare_all_text_files(directory_1::AbstractString, directory_2::AbstractString)::Bool = all(
    map(
        file_name -> compare_text_files(joinpath(directory_1, file_name), joinpath(directory_2, file_name)),
        readdir(directory_1, sort = false),
    ),
)

const version_line_regex_1 = r"^This module was generated with XsdToStruct version \d*\.\d*\.\d* from \"\w*\.xsd\"\.$"
const version_line_regex_2 = r"^\s*XsdToStruct_version = \"\d*\.\d*\.\d*\"$"
function compare_text_files(file_path_1::AbstractString, file_path_2::AbstractString)::Bool
    try
        global iterator_1 = eachline(file_path_1)
    catch
        @info "The first of the given files does not exist or fails to open"
        return false
    end

    try
        global iterator_2 = eachline(file_path_2)
    catch
        @info "The second of the given files does not exist or fails to open"
        return false
    end

    for (index, (line_1, line_2)) in enumerate(zip(iterator_1, iterator_2))
        if line_1 != line_2 &&
           isnothing(match(version_line_regex_1, line_1)) &&
           isnothing(match(version_line_regex_2, line_1))
            println(isnothing(match(version_line_regex_1, line_1)))
            println(isnothing(match(version_line_regex_2, line_1)))
            @info "Files are different at line $index.\nfile 1:\n$line_1\nfile 2:\n$line_2"
            return false
        end
    end

    if !isempty(iterator_1) || !isempty(iterator_2)
        @info "One file is longer than the other."
        return false
    end

    return true
end

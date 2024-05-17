
function get_module_file_path(module_path::AbstractString)
    if isdir(module_path)
        # assume base module is located in given directory and has same name as base part of directory
        module_file_path = joinpath(module_path, (splitpath(module_path) |> last) * ".jl")
    else
        module_file_path = module_path
    end

    if !isfile(module_file_path)
        error("Given path $(module_path) does not lead to the expected module file $(module_file_path).")
    end

    return module_file_path
end

# Skips to the first element found, if already at an element does nothing
function skip_to_element!(reader::EzXML.StreamReader)::Nothing
    while !isnothing(iterate(reader)) && reader.type != EzXML.READER_ELEMENT
    end
    return nothing
end

function get_module_symbol(xml_io::IO)::Symbol
    reader = EzXML.StreamReader(xml_io)
    skip_to_element!(reader)  # first element is the root
    module_name = split(reader.name, ":") |> first  # module name should be the name of namespace of the root
    seekstart(xml_io)  # rewind stream
    return Symbol(module_name)
end

function import_module(module_path::AbstractString, module_symbol::Symbol)::Module
    include(module_path)

    if isdefined(XmlStructLoader, module_symbol)
        @info "Module $module_symbol already loaded"
    else
        @info "Loading module $module_symbol"
        eval(:(@reexport import .$module_symbol))
    end

    return eval(module_symbol)
end

function use_module(module_path::AbstractString, module_symbol::Symbol)::Module
    if isdefined(XmlStructLoader, module_symbol)
        @info "Module $module_symbol already loaded"
    else
        @info "Loading module $module_symbol"

        include(module_path)
        eval(:(@reexport using .$module_symbol))
    end

    return eval(module_symbol)
end

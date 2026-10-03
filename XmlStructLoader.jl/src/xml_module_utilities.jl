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

"""
	get_module_symbol(xml_io::IO)::Symbol

The module a document belongs to: the namespace prefix of its root element, e.g. `TestChoice` for
`<TestChoice:document>`.

pugixml has no streaming mode, so reading one tag means parsing the document, and the load that
follows parses it again. Two passes over the bytes cost a few milliseconds per 30 MB against the
hundreds a load spends building objects, so the second parse is the price of not keeping a second
XML library for this one function.
"""
function get_module_symbol(xml_io::IO)::Symbol
    doc = XmlStructPugixml.parse_buffer(read(xml_io))
    doc == C_NULL && error("pugixml failed to parse XML from IO")
    raw_name = try
        XmlStructPugixml.node_name(XmlStructPugixml.root(doc))
    finally
        XmlStructPugixml.free_doc(doc)
    end
    seekstart(xml_io)  # rewind stream
    module_name = split(raw_name, ":") |> first  # module name should be the name of namespace of the root
    return Symbol(module_name)
end

# A module of a given name is included once per session. Regenerating the file on disk does not
# replace a module already loaded under that name: the types a loaded document holds stay the ones
# that module defined, and a session that regenerates a schema has to be restarted to see the new
# definitions.
function import_module(module_path::AbstractString, module_symbol::Symbol)::Module
    if isdefined(XmlStructLoader, module_symbol)
        @info "Module $module_symbol already loaded"
    else
        @info "Loading module $module_symbol"
        include(module_path)
        eval(:(@reexport import .$module_symbol))
    end

    return eval(module_symbol)
end

# A module of a given name is included once per session. Regenerating the file on disk does not
# replace a module already loaded under that name: the types a loaded document holds stay the ones
# that module defined, and a session that regenerates a schema has to be restarted to see the new
# definitions.
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

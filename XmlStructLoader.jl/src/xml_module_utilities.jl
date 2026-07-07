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

The module name is the namespace prefix of the root element, e.g. `TestChoice` for
`<TestChoice:document>`. pugixml has no incremental/streaming parse mode (unlike libxml2's
StreamReader, which this used to use to stop at the first element without a full DOM parse), so
this does a full parse just to read the root tag - measured against the large synthetic fixture
(bench/run_module_symbol_bench.jl): a full-document-sized parse costs low single-digit ms even on
a 5MB fixture, well under 1% of that fixture's overall `load()` time, and is actually faster than
the old StreamReader-based peek on small documents. Chosen over keeping EzXML as a
single-purpose leftover dependency for this one function.
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

function import_module(module_path::AbstractString, module_symbol::Symbol)::Module
    if isdefined(XmlStructLoader, module_symbol)
        @debug "Module $module_symbol already loaded"
    else
        @debug "Loading module $module_symbol"
        include(module_path)
        eval(:(@reexport import .$module_symbol))
    end

    return eval(module_symbol)
end

function use_module(module_path::AbstractString, module_symbol::Symbol)::Module
    if isdefined(XmlStructLoader, module_symbol)
        @debug "Module $module_symbol already loaded"
    else
        @debug "Loading module $module_symbol"

        include(module_path)
        eval(:(@reexport using .$module_symbol))
    end

    return eval(module_symbol)
end

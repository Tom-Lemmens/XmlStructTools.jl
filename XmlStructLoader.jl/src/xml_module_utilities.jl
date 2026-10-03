"""
	module_symbol_in_file(module_file_path::AbstractString)::Symbol

The name of the module a generated file defines, read from the file.

Taken from the file rather than from a document's root element: a document may bind the schema's
namespace to whatever prefix it likes, or to the default `xmlns`, while the module's name comes
from the schema. Deriving it from the document only agrees with the generator when the two happen
to choose the same name.
"""
function module_symbol_in_file(module_file_path::AbstractString)::Symbol
    for line in eachline(module_file_path)
        # A `module` at the start of a line, so the name quoted in the file's own docstring is
        # not mistaken for the declaration.
        declaration = match(r"^module\s+([A-Za-z_][A-Za-z0-9_]*)", line)
        isnothing(declaration) || return Symbol(declaration.captures[1])
    end
    return error("no module declaration found in $module_file_path")
end

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

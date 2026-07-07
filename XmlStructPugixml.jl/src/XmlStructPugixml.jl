module XmlStructPugixml

import pugixml_jll

# Shipped as a second library product of pugixml_jll (see JuliaPackaging/Yggdrasil PR
# JuliaPackaging/Yggdrasil#14133) rather than compiled locally at Pkg.build() time - no C++
# compiler needed by end users.
const libxmlstructpugixml = pugixml_jll.libxmlstructpugixmlshim

export parse_file,
    parse_buffer,
    free_doc,
    root,
    node_name,
    node_text,
    first_child_element,
    next_sibling_element,
    has_element_children,
    first_attribute,
    next_attribute,
    attribute_name,
    attribute_value,
    each_attribute,
    element_children,
    new_doc,
    doc_as_node,
    append_child_element,
    set_node_text,
    append_attribute,
    save_file

"""
    parse_file(path::AbstractString)::Ptr{Cvoid}

Parse the XML file at `path` into an in-memory pugixml document, returning an owning handle.
Call [`free_doc`](@ref) exactly once on the returned handle when done. Returns `C_NULL` if the
file could not be parsed (bad path, malformed XML).
"""
parse_file(path::AbstractString)::Ptr{Cvoid} = ccall((:pugishim_parse_file, libxmlstructpugixml), Ptr{Cvoid}, (Cstring,), path)

"""
    parse_buffer(data::AbstractVector{UInt8})::Ptr{Cvoid}

Parse an in-memory buffer of XML bytes (e.g. `read(io)` on an arbitrary `IO`) into a document,
returning an owning handle exactly like [`parse_file`](@ref). Returns `C_NULL` on parse failure.
"""
function parse_buffer(data::AbstractVector{UInt8})::Ptr{Cvoid}
    return GC.@preserve data ccall(
        (:pugishim_parse_buffer, libxmlstructpugixml),
        Ptr{Cvoid},
        (Ptr{UInt8}, Csize_t),
        data,
        length(data),
    )
end

"""
    free_doc(doc::Ptr{Cvoid})::Nothing

Free a document handle returned by [`parse_file`](@ref) or [`create_doc`](@ref). Invalidates every
node/attribute handle obtained from it. `C_NULL` is a safe no-op. Call exactly once per handle -
double-free is undefined behavior.
"""
function free_doc(doc::Ptr{Cvoid})::Nothing
    ccall((:pugishim_free_doc, libxmlstructpugixml), Cvoid, (Ptr{Cvoid},), doc)
    return nothing
end

"""
    root(doc::Ptr{Cvoid})::Ptr{Cvoid}

Return the document's root element node handle, or `C_NULL` if the document has none.
"""
root(doc::Ptr{Cvoid})::Ptr{Cvoid} = ccall((:pugishim_root, libxmlstructpugixml), Ptr{Cvoid}, (Ptr{Cvoid},), doc)

"""
    node_name(node::Ptr{Cvoid})::String

The node's tag name, e.g. `"TestElement1"`. Never errors; returns `""` if the node has no name.
Note: pugixml does not split a namespace-prefixed name like `"Foo:document"` into namespace +
local part - the caller gets the literal string as written in the source XML.
"""
node_name(node::Ptr{Cvoid})::String = unsafe_string(ccall((:pugishim_node_name, libxmlstructpugixml), Cstring, (Ptr{Cvoid},), node))

"""
    node_text(node::Ptr{Cvoid})::String

The node's direct text content (pugixml's `child_value()` - the first text/CDATA child only, not
concatenated across all descendants). Never errors; returns `""` if the node has no direct text.
"""
node_text(node::Ptr{Cvoid})::String = unsafe_string(ccall((:pugishim_node_text, libxmlstructpugixml), Cstring, (Ptr{Cvoid},), node))

"""
    first_child_element(node::Ptr{Cvoid})::Ptr{Cvoid}

The node's first **element** child (text/comment/PI nodes are skipped). Returns `C_NULL` if none.
"""
first_child_element(node::Ptr{Cvoid})::Ptr{Cvoid} =
    ccall((:pugishim_first_child_element, libxmlstructpugixml), Ptr{Cvoid}, (Ptr{Cvoid},), node)

"""
    next_sibling_element(node::Ptr{Cvoid})::Ptr{Cvoid}

The node's next **element** sibling (text/comment/PI nodes are skipped). Returns `C_NULL` if none.
"""
next_sibling_element(node::Ptr{Cvoid})::Ptr{Cvoid} =
    ccall((:pugishim_next_sibling_element, libxmlstructpugixml), Ptr{Cvoid}, (Ptr{Cvoid},), node)

"""
    has_element_children(node::Ptr{Cvoid})::Bool

Whether `node` has at least one element child.
"""
has_element_children(node::Ptr{Cvoid})::Bool =
    ccall((:pugishim_has_element_children, libxmlstructpugixml), Cint, (Ptr{Cvoid},), node) != 0

"""
    first_attribute(node::Ptr{Cvoid})::Ptr{Cvoid}

The node's first attribute handle, or `C_NULL` if it has none.
"""
first_attribute(node::Ptr{Cvoid})::Ptr{Cvoid} =
    ccall((:pugishim_first_attribute, libxmlstructpugixml), Ptr{Cvoid}, (Ptr{Cvoid},), node)

"""
    next_attribute(attr::Ptr{Cvoid})::Ptr{Cvoid}

The next attribute handle after `attr`, or `C_NULL` if none.
"""
next_attribute(attr::Ptr{Cvoid})::Ptr{Cvoid} =
    ccall((:pugishim_next_attribute, libxmlstructpugixml), Ptr{Cvoid}, (Ptr{Cvoid},), attr)

"""
    attribute_name(attr::Ptr{Cvoid})::String
"""
attribute_name(attr::Ptr{Cvoid})::String =
    unsafe_string(ccall((:pugishim_attribute_name, libxmlstructpugixml), Cstring, (Ptr{Cvoid},), attr))

"""
    attribute_value(attr::Ptr{Cvoid})::String
"""
attribute_value(attr::Ptr{Cvoid})::String =
    unsafe_string(ccall((:pugishim_attribute_value, libxmlstructpugixml), Cstring, (Ptr{Cvoid},), attr))

"""
    each_attribute(node::Ptr{Cvoid})

Return a `Dict{String,String}` of all of `node`'s attributes. Convenience wrapper over
[`first_attribute`](@ref)/[`next_attribute`](@ref).
"""
function each_attribute(node::Ptr{Cvoid})::Dict{String, String}
    dct = Dict{String, String}()
    attr = first_attribute(node)
    while attr != C_NULL
        dct[attribute_name(attr)] = attribute_value(attr)
        attr = next_attribute(attr)
    end
    return dct
end

"""
    element_children(node::Ptr{Cvoid})::Vector{Ptr{Cvoid}}

Return a `Vector` of `node`'s element children (text/comment/PI nodes skipped). Convenience
wrapper over [`first_child_element`](@ref)/[`next_sibling_element`](@ref).
"""
function element_children(node::Ptr{Cvoid})::Vector{Ptr{Cvoid}}
    result = Ptr{Cvoid}[]
    c = first_child_element(node)
    while c != C_NULL
        push!(result, c)
        c = next_sibling_element(c)
    end
    return result
end

# --- Writing -----------------------------------------------------------------

"""
    new_doc()::Ptr{Cvoid}

Create a new, empty, writable document. Free with [`free_doc`](@ref) exactly like a document
returned by [`parse_file`](@ref) - pugixml does not distinguish "parsed" from "constructed" docs.
"""
new_doc()::Ptr{Cvoid} = ccall((:pugishim_new_doc, libxmlstructpugixml), Ptr{Cvoid}, ())

"""
    doc_as_node(doc::Ptr{Cvoid})::Ptr{Cvoid}

View a document handle (from [`new_doc`](@ref) or [`parse_file`](@ref)) as a plain node handle, so
it can be passed to [`append_child_element`](@ref) to attach the document's root element. Do not
free this handle separately - it is owned by the document, same as any other node handle.
"""
doc_as_node(doc::Ptr{Cvoid})::Ptr{Cvoid} = ccall((:pugishim_doc_as_node, libxmlstructpugixml), Ptr{Cvoid}, (Ptr{Cvoid},), doc)

"""
    append_child_element(node::Ptr{Cvoid}, name::AbstractString)::Ptr{Cvoid}

Append a new child element named `name` to `node` (an ordinary element handle, or a document
viewed via [`doc_as_node`](@ref) - in the latter case this creates the document's root element).
Returns the new child's node handle, or `C_NULL` on failure.
"""
append_child_element(node::Ptr{Cvoid}, name::AbstractString)::Ptr{Cvoid} =
    ccall((:pugishim_append_child_element, libxmlstructpugixml), Ptr{Cvoid}, (Ptr{Cvoid}, Cstring), node, name)

"""
    set_node_text(node::Ptr{Cvoid}, text::AbstractString)::Bool

Set a node's direct text content (finds-or-creates the node's pcdata child and sets its value).
Returns `false` on failure (e.g. `node` is `C_NULL`).
"""
set_node_text(node::Ptr{Cvoid}, text::AbstractString)::Bool =
    ccall((:pugishim_set_node_text, libxmlstructpugixml), Cint, (Ptr{Cvoid}, Cstring), node, text) != 0

"""
    append_attribute(node::Ptr{Cvoid}, name::AbstractString, value::AbstractString)::Ptr{Cvoid}

Append one attribute (name + value) to `node`. Returns the new attribute's handle, or `C_NULL` on
failure. Call once per attribute.
"""
append_attribute(node::Ptr{Cvoid}, name::AbstractString, value::AbstractString)::Ptr{Cvoid} =
    ccall((:pugishim_append_attribute, libxmlstructpugixml), Ptr{Cvoid}, (Ptr{Cvoid}, Cstring, Cstring), node, name, value)

"""
    save_file(doc::Ptr{Cvoid}, path::AbstractString)::Bool

Serialize `doc` to the file at `path` (default pugixml formatting: tab indentation, UTF-8).
Returns `false` on failure (bad path, permissions, ...).
"""
save_file(doc::Ptr{Cvoid}, path::AbstractString)::Bool =
    ccall((:pugishim_save_file, libxmlstructpugixml), Cint, (Ptr{Cvoid}, Cstring), doc, path) != 0

end # module

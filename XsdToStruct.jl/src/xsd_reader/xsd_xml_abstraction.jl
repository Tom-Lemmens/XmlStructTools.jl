# Backend abstraction over XmlStructPugixml (pugixml via ccall) for reading XSD schema files -
# replaces LightXML (see XmlStructLoader.jl/src/xml_parser/xml_abstraction.jl for the analogous
# swap on the XML-instance-loading side, decided together in the same Phase 2 bake-off).
#
# pugixml is not namespace-aware (unlike libxml2/LightXML, which always resolves and strips a
# namespace prefix from a node's name), so element-name matching here strips any literal
# "prefix:" by hand via xsd_element_name - a no-op for every schema in this codebase's test suite
# (they all use an unprefixed default xmlns for schema elements themselves), but correct if a
# schema ever gave the schema elements an explicit prefix.

# Kept as the type name every xsd_reader_*.jl function signature already annotates against.
const XMLElement = Ptr{Cvoid}

xsd_parse_file(path::AbstractString)::Ptr{Cvoid} = XmlStructPugixml.parse_file(path)

function xsd_free(doc::Ptr{Cvoid})::Nothing
    XmlStructPugixml.free_doc(doc)
    return nothing
end

xsd_doc_root(doc::Ptr{Cvoid})::Ptr{Cvoid} = XmlStructPugixml.root(doc)

function xsd_element_name(node::Ptr{Cvoid})::String
    raw = XmlStructPugixml.node_name(node)
    idx = findlast(==(':'), raw)
    return isnothing(idx) ? raw : raw[(idx + 1):end]
end

xsd_attributes_dict(node::Ptr{Cvoid})::Dict{String, String} = XmlStructPugixml.each_attribute(node)

xsd_has_attribute(node::Ptr{Cvoid}, key::AbstractString)::Bool = haskey(xsd_attributes_dict(node), key)

"""
	xsd_attribute(node, key; required=false)

Value of attribute `key` on `node`, or `nothing` if absent. Errors if absent and `required=true`.
"""
function xsd_attribute(node::Ptr{Cvoid}, key::AbstractString; required::Bool = false)
    dct = xsd_attributes_dict(node)
    haskey(dct, key) && return dct[key]
    required && error("Required attribute \"$key\" not found on <$(xsd_element_name(node))>.")
    return nothing
end

xsd_child_elements(node::Ptr{Cvoid})::Vector{Ptr{Cvoid}} = XmlStructPugixml.element_children(node)

"""
	xsd_find_element(node, tag)

First child element of `node` named `tag` (prefix-stripped match), or `nothing`.
"""
function xsd_find_element(node::Ptr{Cvoid}, tag::AbstractString)::Union{Nothing, Ptr{Cvoid}}
    for c in xsd_child_elements(node)
        xsd_element_name(c) == tag && return c
    end
    return nothing
end

"""
	xsd_find_all_elements(node, tag)

All child elements of `node` named `tag` (prefix-stripped match).
"""
function xsd_find_all_elements(node::Ptr{Cvoid}, tag::AbstractString)::Vector{Ptr{Cvoid}}
    return filter(c -> xsd_element_name(c) == tag, xsd_child_elements(node))
end

# Raw text content, matching LightXML's content()/xmlNodeGetContent semantics (unstripped). Only
# ever called on XSD <documentation> elements, which are leaf text nodes - fine to use pugixml's
# child_value() (first text child only, not concatenated across descendants) here.
xsd_content(node::Ptr{Cvoid})::String = XmlStructPugixml.node_text(node)

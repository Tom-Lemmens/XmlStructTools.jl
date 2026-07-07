function parse_xsd_element_field(xsd_element::XMLElement)::FieldData
    # Extract a field name and field type from the given xsd element.

    attribute_dict = xsd_attributes_dict(xsd_element)
    element_name = pop!(attribute_dict, "name")
    element_type = pop!(attribute_dict, "type")

    return FieldData(name = element_name, xsd_type = element_type, xsd_attributes = attribute_dict)
end

function parse_restriction(xsd_modification::XMLElement)::Dict{String, String}
    restriction_dict = Dict{String, String}([("base", xsd_attribute(xsd_modification, "base"))])

    for child in xsd_child_elements(xsd_modification)
        restriction_dict[xsd_element_name(child)] = xsd_attribute(child, "value")
    end

    return restriction_dict
end

function get_xsd_docstring(
        xsd_node::XMLElement;
        extra_docstring::Union{Nothing, AbstractString} = nothing,
    )::Union{Nothing, String}
    annotation_node = xsd_find_element(xsd_node, "annotation")
    if isnothing(annotation_node)
        docstring = nothing
    else
        documentation_node = xsd_find_element(annotation_node, "documentation")
        docstring = isnothing(documentation_node) ? nothing : xsd_content(documentation_node)
    end

    # append to option extra docstring
    if !isnothing(extra_docstring)
        docstring = isnothing(docstring) ? extra_docstring : extra_docstring * "\n" * docstring
    end

    return docstring
end

sub_module_name(parent_name::AbstractString)::String = "$(parent_name)Types"

"""
	derive_namespace_name(target_namespace::AbstractString)::String

Fallback module name for a schema whose target namespace has no explicit xmlns prefix bound to it
(so there is no author-chosen short name to read off the schema root element directly). Takes the
last segment of the namespace URI/URN (handles both "urn:...:pacs.008.001.09"-style and
"http://example.com/foo/bar"-style namespaces) and sanitizes it into a valid Julia identifier,
matching the sanitization xsd_to_struct_module already applies to filename-derived module names.
"""
function derive_namespace_name(target_namespace::AbstractString)::String
    last_segment = target_namespace |> x -> split(x, r"[:/]") |> x -> filter(!isempty, x) |> last
    sanitized = replace(last_segment, forbidden_characters_regex => "_")
    return isdigit(first(sanitized)) ? "_$sanitized" : sanitized
end

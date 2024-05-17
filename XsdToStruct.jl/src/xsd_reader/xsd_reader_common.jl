
function parse_xsd_element_field(xsd_element::XMLElement)::FieldData
    # Extract a field name and field type from the given xsd element.

    attribute_dict = attributes_dict(xsd_element)
    element_name = pop!(attribute_dict, "name")
    element_type = pop!(attribute_dict, "type")

    return FieldData(name = element_name, xsd_type = element_type, xsd_attributes = attribute_dict)
end

function parse_restriction(xsd_modification::XMLElement)::Dict{String,String}
    restriction_dict = Dict{String,String}([("base", attribute(xsd_modification, "base"))])

    for child in child_elements(xsd_modification)
        restriction_dict[LightXML.name(child)] = attribute(child, "value")
    end

    return restriction_dict
end

function get_xsd_docstring(
    xsd_node::XMLElement;
    extra_docstring::Union{Nothing,AbstractString} = nothing,
)::Union{Nothing,String}
    annotation_node = find_element(xsd_node, "annotation")
    if isnothing(annotation_node)
        docstring = nothing
    else
        documentation_node = find_element(annotation_node, "documentation")
        docstring = isnothing(documentation_node) ? nothing : content(documentation_node)
    end

    # append to option extra docstring
    if !isnothing(extra_docstring)
        docstring = isnothing(docstring) ? extra_docstring : extra_docstring * "\n" * docstring
    end

    return docstring
end

sub_module_name(parent_name::AbstractString)::String = "$(parent_name)Types"

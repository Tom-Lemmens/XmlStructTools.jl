
include("xml_abstraction.jl")
include("xml_parser_type_info.jl")
include("xml_parser_in_module.jl")
include("xml_parser_not_module.jl")

PathOrIO = Union{IO,AbstractString}

function construct_xml_object(xml::PathOrIO, module_ref::Module; validate::Bool = true)
    root_attributes = root_attributes_workaround(xml)

    constructed_object = readxmlfile(xml) do xml_doc
        xml_root = docroot(xml_doc)
        return construct_xml_root_object(xml_root, module_ref, root_attributes, validate = validate)
    end
    return constructed_object
end

# This is a workaround, both LightXML and EzXML don't return all the needed attributes of the root element
const ELEMENT_REGEX = r"<([^\?][^<>]*[^\?])>"
function root_attributes_workaround(xml_path::AbstractString)::Dict{String,String}
    local root_attributes
    # manually search for line with root(first) element
    for line in eachline(xml_path)
        element_match = match(ELEMENT_REGEX, line)
        if !isnothing(element_match)  # found root element of document
            root_attributes = get_root_attributes(element_match.match)
            break
        end
    end
    return root_attributes
end

function root_attributes_workaround(xml_io::IO)::Dict{String,String}
    local root_attributes
    # manually search for line with root element
    for line in eachline(xml_io)
        element_match = match(ELEMENT_REGEX, line)
        if !isnothing(element_match)  # found root element of document
            root_attributes = get_root_attributes(element_match.match)
            break
        end
    end
    seekstart(xml_io)  # rewind stream
    return root_attributes
end

# extract attributes with regex
const ROOT_ATTRIBUTES_REGEX = r"([\w:]+)=\"(.*?)\""
function get_root_attributes(line::AbstractString)
    matches = eachmatch(ROOT_ATTRIBUTES_REGEX, line)
    root_attributes = Dict(match.captures for match in matches)
    return root_attributes
end

function construct_xml_root_object(
    @nospecialize(xml_root::UnifiedXMLElement),
    module_ref::Module,
    root_attributes::Dict{<:AbstractString,<:AbstractString};
    validate::Bool = true,
)
    root_type = module_ref.__meta.root_type
    root_name = name(xml_root)
    root_attributes["__root_name"] = root_name

    @debug "Constructing root object of type $root_type from node $root_name with validate=$validate"

    # recurse through child nodes
    child_object_dict = construct_xml_node_child_objects(xml_root, module_ref, validate)

    # add xml_attributes and validate
    merge!(child_object_dict, Dict(:__xml_attributes => root_attributes, :__validated => validate))
    # construct object with child objects
    child_string = join(["$key =>\n$value" for (key, value) in child_object_dict], "\n")
    @debug "Constructing root element from children:\n$child_string"
    constructed_object = root_type(; child_object_dict...)

    return constructed_object
end

"""
	construct_xml_node_object(xml_node::UnifiedXMLElement, struct_type::DataType, module_ref::Module, validate::Bool, default_value)

Construct object of type "struct_type" with the data of "xml_node", the given module is used for the
struct definitions. If the given type is not defined by the module we use content(xml_node) and parse it into
struct_type, if needed with Base.parse. If validate is true and if the type has any associated restrictions in the
module the data is checked with respect to these restrictions.
"""

function construct_xml_node_object(node::XmlStructLoaderNode, module_ref::Module, validate::Bool)
    @debug "Constructing object of type $(node.type) from node $(name(node.node))"

    # check if type is from module
    if type_in_module(node.type, module_ref)
        constructed_object = parse_xml_node_in_module(node, module_ref, validate)
    elseif node.type <: AbstractVector
        constructed_object = _parse_xml_node_not_module(node, module_ref, validate)
    else
        constructed_object = parse_xml_node_not_module(node.node, node.type, module_ref, validate, get_default(node))
    end

    return constructed_object
end

get_node_content(@nospecialize(xml_node::UnifiedXMLElement))::String = strip(content(xml_node))

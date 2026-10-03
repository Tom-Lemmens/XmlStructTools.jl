include("xml_abstraction.jl")
include("xml_parser_type_info.jl")
include("xml_parser_in_module.jl")
include("xml_parser_not_module.jl")

PathOrIO = Union{IO, AbstractString}

function construct_xml_object(xml::PathOrIO, module_ref::Module; validate::Bool = true)
    constructed_object = readxmlfile(xml) do xml_doc
        xml_root = docroot(xml_doc)
        root_attributes = getattributes_dict(xml_root)
        return construct_xml_root_object(xml_root, module_ref, root_attributes, validate = validate)
    end
    return constructed_object
end

function construct_xml_root_object(
        @nospecialize(xml_root::UnifiedXMLElement),
        module_ref::Module,
        root_attributes::Dict{<:AbstractString, <:AbstractString};
        validate::Bool = true,
    )
    root_type = module_ref.__meta.root_type
    root_name = name(xml_root)
    root_attributes["__root_name"] = root_name

    @debug "Constructing root object of type $root_type from node $root_name with validate=$validate"

    # recurse through child nodes
    child_object_dict = _child_fields(root_type, xml_root, module_ref, validate)

    # add xml_attributes and validate
    merge!(child_object_dict, Dict(:__xml_attributes => root_attributes, :__validated => validate))
    # construct object with child objects
    @debug begin
        child_string = join(["$key =>\n$value" for (key, value) in child_object_dict], "\n")
        "Constructing root element from children:\n$child_string"
    end
    constructed_object = root_type(; child_object_dict...)

    return constructed_object
end

get_node_content(@nospecialize(xml_node::UnifiedXMLElement))::String = strip(content(xml_node))


include("xsd_reader_common.jl")
include("xsd_reader_complex_node.jl")
include("xsd_reader_simple_node.jl")

function read_xsd(xsd_path::AbstractString)::SchemaTreeNode
    @debug "Reading xsd file: $(xsd_path)"
    xsd_doc = parse_file(xsd_path)

    xsd_root = root(xsd_doc)
    if LightXML.name(xsd_root) != "schema"
        error("Given xml document is not a valid XSD, root element is not a schema element.")
    end

    xsd_tree = create_xsd_tree(xsd_root)
    @debug "Constructed xsd tree:\n$(xsd_tree)"

    free(xsd_doc)

    return xsd_tree
end

# Function to create xsd tree starting from a given xsd root element
function create_xsd_tree(xsd_root::XMLElement)::SchemaTreeNode
    @debug "Starting to create xsd tree"

    root_opening_tag = first(split(string(xsd_root), "\n"))
    xml_namespace_regex = r"xmlns:([a-zA-Z0-9]+)="
    regex_match = match(xml_namespace_regex, root_opening_tag)
    xml_namespace = first([match for match in regex_match.captures if match != "xsi"])  # get first match different from "xsi"
    node_attributes = attributes_dict(xsd_root)

    child_nodes = Vector{AbstractTreeNode}()
    group_nodes = Vector{ComplexTreeNode}()
    root_field = nothing
    for xsd_child_element in child_elements(xsd_root)
        @debug "Parsing $(xsd_child_element)"

        if has_attribute(xsd_child_element, "type")
            root_field = parse_xsd_element_field(xsd_child_element)
        else
            child_name = LightXML.name(xsd_child_element)

            if child_name == "element"
                root_field, child_node = parse_xsd_element_child(xsd_child_element, tree_name)
                push!(child_nodes, child_node)
            elseif child_name == "complexType"
                child_node = parse_xsd_complex_type(xsd_child_element)
                push!(child_nodes, child_node)
            elseif child_name == "simpleType"
                child_node = parse_xsd_simple_type(xsd_child_element)
                push!(child_nodes, child_node)
            elseif child_name == "group"
                group_node = parse_xsd_group(xsd_child_element)
                push!(group_nodes, group_node)
            else
                @warn("Unhandled child:\n$xsd_child_element")
            end
        end
    end

    if isnothing(root_field)
        error("No root element defined in the given schema.")
    end

    if isempty(child_nodes)
        error("No fields or structs are defined in the given schema.")
    end

    return create_SchemaTreeNode(
        name = xml_namespace,
        attributes = node_attributes,
        root_field = root_field,
        group_nodes = group_nodes,
        child_nodes = child_nodes,
    )
end

"""
    parse_xsd_element_child(
        xsd_element::XMLElement,
        parent_name::AbstractString
    )::Tuple{FieldData, AbstractTreeNode}

Extract child node from xsd element with a type defined inside the element
"""
function parse_xsd_element_child(
    xsd_element::XMLElement,
    parent_name::AbstractString,
)::Tuple{FieldData,AbstractTreeNode}
    attribute_dict = attributes_dict(xsd_element)
    field_name = pop!(attribute_dict, "name")
    type_name = field_name
    field = FieldData(
        name = field_name,
        xsd_type = type_name,
        xsd_attributes = attribute_dict,
        sub_module = sub_module_name(parent_name),
    )

    # documentation can be given on this level
    xsd_docstring = get_xsd_docstring(xsd_element)

    type_node = find_element(xsd_element, "complexType")
    if isnothing(type_node)
        type_node = find_element(xsd_element, "simpleType")
        child_node =
            parse_xsd_simple_type(type_node, type_name, sub_module_name(parent_name), extra_docstring = xsd_docstring)

        if isnothing(type_node)
            @error("Unable to determine type for node:\n$(xsd_element)")
        end
    else
        child_node = parse_xsd_complex_type(type_node, type_name, sub_module_name(parent_name))
    end

    return field, child_node
end

function parse_xsd_group(xsd_group::XMLElement)::ComplexTreeNode
    node_attributes = attributes_dict(xsd_group)
    group_name = pop!(node_attributes, "name")
    xsd_sequence = find_element(xsd_group, "sequence")

    group_node = ComplexTreeNode(common_data = CommonNodeData(name = group_name, attributes = node_attributes))
    parse_xsd_complex_content_sequence!(group_node, xsd_sequence)

    return group_node
end

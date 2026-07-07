include("xsd_xml_abstraction.jl")
include("xsd_reader_common.jl")
include("xsd_reader_complex_node.jl")
include("xsd_reader_simple_node.jl")

function read_xsd(xsd_path::AbstractString)::SchemaTreeNode
    @debug "Reading xsd file: $(xsd_path)"
    xsd_doc = xsd_parse_file(xsd_path)

    xsd_root = xsd_doc_root(xsd_doc)
    if xsd_element_name(xsd_root) != "schema"
        error("Given xml document is not a valid XSD, root element is not a schema element.")
    end

    xsd_tree = create_xsd_tree(xsd_root)
    @debug "Constructed xsd tree:\n$(xsd_tree)"

    xsd_free(xsd_doc)

    return xsd_tree
end

# Function to create xsd tree starting from a given xsd root element
function create_xsd_tree(xsd_root::XMLElement)::SchemaTreeNode
    @debug "Starting to create xsd tree"

    node_attributes = xsd_attributes_dict(xsd_root)
    # The schema root declares several xmlns bindings (its own target namespace, the XMLSchema
    # meta-namespace, often xsi too) under whatever prefixes the schema author happened to pick -
    # some schemas bind the XMLSchema meta-namespace to "xs"/"xsd" and leave their OWN target
    # namespace on the unprefixed default xmlns (real-world ISO 20022 schemas do this), which is
    # the opposite convention from this repo's own test fixtures (explicit prefix for their own
    # namespace, default xmlns for the meta-namespace) - excluding known meta-prefixes by name
    # guesses (just "xsi") silently picked the wrong one. Matching by VALUE against the schema's
    # own declared targetNamespace is unambiguous regardless of prefix-naming convention.
    haskey(node_attributes, "targetNamespace") ||
        error("Given XSD has no targetNamespace attribute on its schema root element.")
    target_namespace = node_attributes["targetNamespace"]
    xmlns_keys = filter(
        k -> startswith(k, "xmlns:") && node_attributes[k] == target_namespace,
        collect(keys(node_attributes)),
    )
    xml_namespace = if !isempty(xmlns_keys)
        last(split(first(xmlns_keys), ":"))
    else
        # No explicit prefix is bound to the target namespace - the schema puts its own namespace
        # on the unprefixed default xmlns instead (real-world ISO 20022 schemas do this). Derive a
        # module name from the namespace URI itself rather than erroring, since this is a valid
        # and common XSD authoring style, not a malformed schema.
        derive_namespace_name(target_namespace)
    end

    child_nodes = Vector{AbstractTreeNode}()
    group_nodes = Vector{ComplexTreeNode}()
    root_field = nothing
    for xsd_child_element in xsd_child_elements(xsd_root)
        @debug "Parsing $(xsd_child_element)"

        if xsd_has_attribute(xsd_child_element, "type")
            root_field = parse_xsd_element_field(xsd_child_element)
        else
            child_name = xsd_element_name(xsd_child_element)

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
    )::Tuple{FieldData, AbstractTreeNode}
    attribute_dict = xsd_attributes_dict(xsd_element)
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

    type_node = xsd_find_element(xsd_element, "complexType")
    if isnothing(type_node)
        type_node = xsd_find_element(xsd_element, "simpleType")
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
    node_attributes = xsd_attributes_dict(xsd_group)
    group_name = pop!(node_attributes, "name")
    xsd_sequence = xsd_find_element(xsd_group, "sequence")

    group_node = ComplexTreeNode(common_data = CommonNodeData(name = group_name, attributes = node_attributes))
    parse_xsd_complex_content_sequence!(group_node, xsd_sequence)

    return group_node
end

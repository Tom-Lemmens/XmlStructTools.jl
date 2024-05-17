
function parse_extension(xsd_extension::XMLElement)::Tuple{String,Dict{String,String}}
    extension_base_type = attribute(xsd_extension, "base")
    extension_attributes = Dict{String,String}()

    # get added attributes
    extension_attributes = Dict{String,String}()
    for attribute_element in xsd_extension["attribute"]
        merge!(extension_attributes, attributes_dict(attribute_element))
    end

    return extension_base_type, extension_attributes
end

function parse_simple_content(xsd_simple_content::XMLElement)::FieldData

    # We are either restricting or extending an existing simpleType
    restriction_element = find_element(xsd_simple_content, "restriction")
    if !isnothing(restriction_element)
        restrictions_dict = parse_restriction(restriction_element)
        @warn "parse_simple_content restriction is not yet fully implemented."
    else
        extension_element = find_element(xsd_simple_content, "extension")
        extension_base_type, attributes = parse_extension(extension_element)
        field = FieldData(name = "value", xsd_type = extension_base_type, xsd_attributes = attributes)
    end

    return field
end

function parse_complex_content!(complex_node::ComplexTreeNode, xsd_complex_content::XMLElement)::Nothing
    xsd_content_name = LightXML.name(xsd_complex_content)
    @debug "Parsing complexContent element:\n$(xsd_content_name)"

    if xsd_content_name == "sequence"
        parse_xsd_complex_content_sequence!(complex_node, xsd_complex_content)
    elseif xsd_content_name == "element"
        parse_xsd_complex_content_element!(complex_node, xsd_complex_content)
    elseif xsd_content_name == "group"
        parse_xsd_complex_content_group!(complex_node, xsd_complex_content)
    elseif xsd_content_name == "choice"
        parse_xsd_complex_content_choice!(complex_node, xsd_complex_content)
    else
        @warn "Unhandled child:\n$(xsd_complex_content)"
    end

    return
end

function parse_xsd_complex_content_sequence!(complex_node::ComplexTreeNode, xsd_sequence::XMLElement)::Nothing
    for child_element in child_elements(xsd_sequence)
        parse_complex_content!(complex_node, child_element)
    end

    return
end

function parse_xsd_complex_content_element!(complex_node::ComplexTreeNode, xsd_element::XMLElement)::Nothing
    type_attribute = attribute(xsd_element, "type", required = false)

    if isnothing(type_attribute)
        # type defined locally inside element
        field_data, child = parse_xsd_element_child(xsd_element, name(complex_node))
        push!(complex_node.child_nodes, child)
        push!(complex_node.child_fields, field_data)
        push!(complex_node.field_ordering, field_data.name)
    else
        # type defined outside
        field_data = parse_xsd_element_field(xsd_element)
        push!(complex_node.fields, field_data)
        push!(complex_node.field_ordering, field_data.name)
    end

    return nothing
end

function parse_xsd_complex_content_group!(complex_node::ComplexTreeNode, xsd_group::XMLElement)::Nothing
    node_attributes = attributes_dict(xsd_group)

    group_name = pop!(node_attributes, "ref")
    group_name = last(split(group_name, ":"))  # group name without namespace

    place_holder_field = GroupFieldData(name = group_name, xsd_attributes = node_attributes)

    push!(complex_node.fields, place_holder_field)
    push!(complex_node.field_ordering, group_name)

    return
end

function parse_xsd_complex_content_choice!(complex_node::ComplexTreeNode, xsd_choice::XMLElement)::Nothing
    choice_name = name(complex_node)

    @debug "Parsing choice content in $choice_name"

    # create conflict free name for choice field
    n_choices = length(get_all_fields_of_type(complex_node, ChoiceFieldData))
    field_name = "__$(choice_name)_choice_$(n_choices+1)"

    # parse content of choice with a temporary complex node
    tmp_complex_node =
        ComplexTreeNode(common_data = CommonNodeData(name = choice_name, sub_module = sub_module_name(choice_name)))
    for child_element in child_elements(xsd_choice)
        parse_complex_content!(tmp_complex_node, child_element)
    end

    # create choice field object
    field = ChoiceFieldData(
        name = field_name,
        choice_options = get_all_fields(tmp_complex_node),
        xsd_attributes = attributes_dict(xsd_choice),
    )

    # update parent node
    push!(complex_node.fields, field)
    append!(complex_node.child_nodes, tmp_complex_node.child_nodes)
    push!(complex_node.field_ordering, field_name)
    # only add the child nodes, the fields are not needed since these do not have to be written in the struct definition

    return nothing
end

function parse_complex_content_extension(common_data::CommonNodeData, xsd_extension::XMLElement)::ExtensionTreeNode
    extension_node = ComplexTreeNode(common_data = CommonNodeData(name = common_data.name * "_extension"))
    complex_content = (child for child in child_elements(xsd_extension) if LightXML.name(child) != "annotation")

    if !isempty(complex_content)
        parse_complex_content!(extension_node, first(complex_content))  # complex_content should be unique
    end

    xsd_attributes = attributes_dict(xsd_extension)
    base_name = last(split(pop!(xsd_attributes, "base"), ":"))
    merge!(common_data.attributes, xsd_attributes)

    return ExtensionTreeNode(common_data = common_data, node_content = extension_node, base_name = base_name)
end

function parse_xsd_complex_type(
    xsd_complex::XMLElement,
    type_name::Union{Nothing,AbstractString} = nothing,
    sub_module::Union{Nothing,AbstractString} = nothing,
)::Union{ComplexTreeNode,SimpleTreeNode,ExtensionTreeNode}
    node_attributes = attributes_dict(xsd_complex)
    xsd_docstring = get_xsd_docstring(xsd_complex)

    # default to name attribute of the given xsd element
    if isnothing(type_name)
        type_name = pop!(node_attributes, "name")
    end

    # Either we have simpleContent or complexContent, complexContent can be implicit
    simple_content = find_element(xsd_complex, "simpleContent")
    if !isnothing(simple_content)
        field = parse_simple_content(simple_content)
        merge!(node_attributes, field.xsd_attributes)

        @debug "Creating simple node from simpleContent for $(type_name)"
        parsed_node = SimpleTreeNode(
            common_data = CommonNodeData(
                name = type_name,
                attributes = node_attributes,
                docstring = xsd_docstring,
                sub_module = sub_module,
            ),
            field = field,
        )
    else
        common_data = CommonNodeData(
            name = type_name,
            attributes = node_attributes,
            docstring = xsd_docstring,
            sub_module = sub_module,
        )

        # complexContent can be explicit or abbreviated
        complex_content = find_element(xsd_complex, "complexContent")
        if !isnothing(complex_content)
            child_element = first(child_elements(complex_content))  # should only be one
            if LightXML.name(child_element) == "extension"
                parsed_node = parse_complex_content_extension(common_data, child_element)
            elseif LightXML.name(child_element) == "restriction"
                @warn "Parsing complexContent restrictions is not yet implemented"
                parsed_node = ComplexTreeNode(common_data = common_data)
            end
        else
            @debug "Creating complex node from implicit complexContent for $(type_name)"
            parsed_node = ComplexTreeNode(common_data = common_data)

            xsd_complex_children =
                (child for child in child_elements(xsd_complex) if LightXML.name(child) != "annotation")
            if !isempty(xsd_complex_children)
                xsd_complex_content = first(xsd_complex_children)
                parse_complex_content!(parsed_node, xsd_complex_content)
            end
        end
    end

    return parsed_node
end

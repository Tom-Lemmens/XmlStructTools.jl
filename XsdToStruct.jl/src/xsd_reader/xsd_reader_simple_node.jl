
function parse_xsd_simple_type(
    xsd_simple::XMLElement,
    type_name::Union{Nothing,AbstractString} = nothing,
    sub_module::Union{Nothing,AbstractString} = nothing;
    extra_docstring::Union{Nothing,AbstractString} = nothing,
)::Union{UnionTreeNode,SimpleTreeNode}
    node_attributes = attributes_dict(xsd_simple)

    # default to name specified in xsd element
    if isnothing(type_name)
        type_name = pop!(node_attributes, "name")
    end

    xsd_docstring = get_xsd_docstring(xsd_simple, extra_docstring = extra_docstring)

    common_data = CommonNodeData(;
        name = type_name,
        attributes = node_attributes,
        docstring = xsd_docstring,
        sub_module = sub_module,
    )

    if is_union(xsd_simple)
        @debug "Creating union node for $(type_name)"
        xsd_union = find_element(xsd_simple, "union")

        nodes = Vector{AbstractTreeNode}()
        for (index, union_child) in enumerate(child_elements(xsd_union))
            child_type_name = "type_$(index)"
            this_sub_module = sub_module_name(type_name)
            this_node = parse_xsd_simple_type(union_child, child_type_name, this_sub_module)
            push!(nodes, this_node)
        end

        return UnionTreeNode(; common_data = common_data, union_nodes = nodes)
    else
        @debug "Creating simple node for $(type_name)"

        xsd_restriction = find_element(xsd_simple, "restriction")
        restrictions = parse_restriction(xsd_restriction)

        if isnothing(sub_module)
            field_data = FieldData(; name = "value", xsd_type = pop!(restrictions, "base"))
        else
            base_type = pop!(restrictions, "base")

            # check if the base type already specifies a module
            split_type = split(base_type, ":")

            if length(split_type) == 1
                # no module specified
                field_data = FieldData(; name = "value", xsd_type = base_type, sub_module = sub_module)
            else
                # module specified, get type name and qualified module name
                base_type = pop!(split_type)

                field_data = FieldData(; name = "value", xsd_type = base_type, sub_module = join(split_type, "."))
            end
        end

        return SimpleTreeNode(; common_data = common_data, field = field_data, restrictions = restrictions)
    end
end

function is_union(xsd_simple::XMLElement)
    return !isnothing(find_element(xsd_simple, "union"))
end

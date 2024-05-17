
function process_xsd_tree!(xsd_tree::SchemaTreeNode)
    for node_index in get_node_indices_of_type(xsd_tree, ExtensionTreeNode)
        resolve_extension_node!(xsd_tree, node_index)
    end

    for node in get_nodes_of_type(xsd_tree, ComplexTreeNode)
        substitute_group!(node, xsd_tree.group_nodes)
    end

    remove_simple_boolean!(xsd_tree)

    @debug "processed xsd tree\n$(xsd_tree)"
end

function resolve_extension_node!(xsd_tree, node_index)::Nothing
    extension_node = xsd_tree.child_nodes[node_index]
    base_node_ind = findfirst(node -> name(node) == extension_node.base_name, xsd_tree.child_nodes)
    base_node = xsd_tree.child_nodes[base_node_ind]

    append!(extension_node.base_fields, base_node.fields)
    append!(extension_node.base_children, base_node.child_nodes)
    append!(extension_node.base_child_fields, base_node.child_fields)
    append!(extension_node.base_field_ordering, base_node.field_ordering)

    return nothing
end

function substitute_group!(node::ComplexTreeNode, group_nodes::Vector{ComplexTreeNode})

    # recurse through children first
    for child_node in get_nodes_of_type(node.child_nodes, ComplexTreeNode)
        substitute_group!(child_node, group_nodes)
    end

    group_indices = get_field_indices_of_type(node, GroupFieldData)

    # group substitutions can be nested, keep looping until no more remain
    while !isempty(group_indices)
        for group_field_index in reverse(group_indices)
            group_field_name = node.fields[group_field_index].name  # note: a group is never in a child field
            @debug "Looking for substitute for $group_field_name in $(name(node))"

            matching_group_node = first(filter(x -> name(x) == group_field_name, group_nodes))

            for (offset, field) in enumerate(matching_group_node.fields)
                insert!(node.fields, group_field_index + offset, field)
            end
            for (offset, field_name) in enumerate(matching_group_node.field_ordering)
                insert!(node.field_ordering, group_field_index + offset, field_name)
            end

            @debug "Replaced $(node.fields[group_field_index].name) with group node $(name(matching_group_node))"
            deleteat!(node.fields, group_field_index)
            deleteat!(node.field_ordering, group_field_index)
        end

        # refresh group indices
        group_indices = get_field_indices_of_type(node, GroupFieldData)
    end
end

function remove_simple_boolean!(xsd_tree::SchemaTreeNode)::Nothing
    @debug "Removing boolean based simple types"

    booleans = is_boolean.(xsd_tree.child_nodes)
    boolean_names = Vector{String}(name.(xsd_tree.child_nodes[booleans]))

    # go through complex nodes
    for node in get_nodes_of_type(xsd_tree, ComplexTreeNode)
        remove_simple_boolean!(node, boolean_names)
    end

    deleteat!(xsd_tree.child_nodes, booleans)

    return nothing
end

function remove_simple_boolean!(xsd_node::ComplexTreeNode, boolean_node_names::Vector{<:AbstractString})::Nothing

    # recurse through children
    for node in get_nodes_of_type(xsd_node, ComplexTreeNode)
        remove_simple_boolean!(node, boolean_node_names)
    end

    booleans = is_boolean.(xsd_node.child_nodes)
    child_boolean_node_names = name.(xsd_node.child_nodes[booleans])

    for field in get_all_fields(xsd_node)
        if field.julia_type in child_boolean_node_names || field.julia_type in boolean_node_names
            field.julia_type = "Bool"
        end
    end

    deleteat!(xsd_node.child_nodes, booleans)

    return nothing
end

function get_boolean_names(xsd_node::AbstractTreeNode)::Vector{String}
    simple_nodes = get_nodes_of_type(xsd_node.child_nodes, SimpleTreeNode)
    booleans = is_boolean.(simple_nodes)

    boolean_names = getproperty.(simple_nodes[booleans], :name)

    return boolean_names
end

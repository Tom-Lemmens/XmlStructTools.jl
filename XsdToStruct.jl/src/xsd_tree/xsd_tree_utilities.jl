
(get_nodes_of_type(xsd_node::Union{ComplexTreeNode,SchemaTreeNode}, ::Type{T})::Vector{T}) where {T<:AbstractTreeNode} =
    get_nodes_of_type(xsd_node.child_nodes, T)

(get_nodes_of_type(nodes::Vector{<:AbstractTreeNode}, ::Type{T})::Vector{T}) where {T<:AbstractTreeNode} =
    filter(x -> typeof(x) == T, nodes)

function get_node_indices_of_type(
    xsd_node::Union{ComplexTreeNode,SchemaTreeNode},
    ::Type{T},
)::Vector{Int64} where {T<:AbstractTreeNode}
    return get_node_indices_of_type(xsd_node.child_nodes, T)
end

(get_node_indices_of_type(nodes::Vector{<:AbstractTreeNode}, ::Type{T})::Vector{Int64}) where {T<:AbstractTreeNode} =
    findall(x -> typeof(x) == T, nodes)

function has_node_of_type(children::Vector{<:AbstractTreeNode}, ::Type{T})::Bool where {T<:AbstractTreeNode}
    has_nodes_of_type = false

    for child in children
        if typeof(child) == T
            # check if node type matches
            has_nodes_of_type = true
        elseif typeof(child) == ComplexTreeNode
            # check if any child nodes match
            has_nodes_of_type = has_node_of_type(child.child_nodes, T)
        end

        if has_nodes_of_type
            # we already found a matching note stop looking
            break
        end
    end

    return has_nodes_of_type
end

function has_xsd_type_field(complex_node::ComplexTreeNode, xsd_type_name::AbstractString)::Bool
    # check if any child nodes match
    found = has_xsd_type_node(complex_node.child_nodes, xsd_type_name)
    if found
        # we already found a matching node stop looking
        return found
    end

    # check if any fields match
    for field in get_all_fields(complex_node)
        found = has_xsd_type(field, xsd_type_name)

        if found
            # we already found a matching node stop looking
            return found
        end
    end

    return found
end

function has_xsd_type_field(extension_node::ExtensionTreeNode, xsd_type_name::AbstractString)::Bool
    # check if own content matches
    found = has_xsd_type_node(extension_node.node_content, xsd_type_name)
    if found
        # we already found a matching node stop looking
        return found
    end

    # check if any child nodes match
    found = has_xsd_type_node(extension_node.base_children, xsd_type_name)
    if found
        # we already found a matching node stop looking
        return found
    end

    # check if any fields match
    for field in extension_node.base_fields
        found = has_xsd_type(field, xsd_type_name)

        if found
            # we already found a matching node stop looking
            return found
        end
    end

    return found
end

function has_xsd_type_node(children::Vector{AbstractTreeNode}, xsd_type_name::AbstractString)::Bool
    found = false

    for child in children
        if typeof(child) == SimpleTreeNode
            # check if node base type matches
            found = strip_xsd_namespace(child.field.xsd_type) == xsd_type_name
        elseif typeof(child) == ComplexTreeNode || typeof(child) == ExtensionTreeNode
            found = has_xsd_type_field(child, xsd_type_name)
        end

        if found
            # we already found a matching note stop looking
            break
        end
    end

    return found
end

function create_SchemaTreeNode(;
    name::AbstractString,
    attributes::OptionalDictStringString,
    root_field::FieldData,
    group_nodes::Vector{ComplexTreeNode} = Vector{ComplexTreeNode}(),
    child_nodes::Vector{AbstractTreeNode} = Vector{AbstractTreeNode}(),
)::SchemaTreeNode
    has_simple_nodes = (has_node_of_type(child_nodes, SimpleTreeNode) || has_node_of_type(group_nodes, SimpleTreeNode))
    has_complex_nodes =
        (has_node_of_type(child_nodes, ComplexTreeNode) || has_node_of_type(group_nodes, ComplexTreeNode))

    requires_TimeZones = has_xsd_type_node(child_nodes, "dateTime")
    requires_Dates = requires_TimeZones || has_xsd_type_node(child_nodes, "date")

    return SchemaTreeNode(
        common_data = CommonNodeData(name = name, attributes = attributes),
        root_field = root_field,
        group_nodes = group_nodes,
        child_nodes = child_nodes,
        has_simple_nodes = has_simple_nodes,
        has_complex_nodes = has_complex_nodes,
        requires_TimeZones = requires_TimeZones,
        requires_Dates = requires_Dates,
    )
end

"""
    get_field_indices_of_type(
        node::Union{ComplexTreeNode, SchemaTreeNode},
        ::Type{T}
    ) where T <: AbstractFieldData

Find indices for all elements in the fields attribute of the given node which are of the given FieldData type.
Note that this does not include the child fields in the case of a ComplexTreeNode.
"""
function get_field_indices_of_type(node::Union{ComplexTreeNode,SchemaTreeNode}, ::Type{T}) where {T<:AbstractFieldData}
    return findall(field -> field isa T, node.fields)
end

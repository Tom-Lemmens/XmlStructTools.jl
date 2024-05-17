function check_node_ready(xsd_node::AbstractTreeNode, xsd_module_builder::XSDStructModuleBuilderType)::Bool
    required_types = get_required_types(xsd_node, xsd_module_builder)
    @debug "Types required for node $(name(xsd_node)): $required_types"

    undefined_types = filter(type -> !is_defined(type, xsd_module_builder), required_types)

    ready = isempty(undefined_types)

    if !ready
        @debug "Node $(name(xsd_node)) not ready."
        @debug "Undefined types: $(undefined_types)"
    end

    return ready
end

function get_required_types(xsd_node::ComplexTreeNode, xsd_module_builder::XSDStructModuleBuilderType)::Vector{String}
    required_types = required_julia_types(xsd_node)

    # add required types of child nodes
    required_types = mapreduce(
        child_node -> get_required_types(child_node, xsd_module_builder),
        append!,
        xsd_node.child_nodes,
        init = required_types,
    )

    # remove child types, will be written in submodule
    child_type_names = qualified_name.(xsd_node.child_nodes)
    filter!(required_type -> required_type ∉ child_type_names, required_types)

    return required_types
end

function get_required_types(xsd_node::ExtensionTreeNode, xsd_module_builder::XSDStructModuleBuilderType)::Vector{String}

    # own types
    required_types = get_required_types(xsd_node.node_content, xsd_module_builder)

    # base should also be defined to ensure all other types are defined
    push!(required_types, xsd_node.base_name)

    return required_types
end

function get_required_types(xsd_node::SimpleTreeNode, xsd_module_builder::XSDStructModuleBuilderType)::Vector{String}
    required_type = qualified_type(xsd_node.field, xsd_module_builder.module_name)

    return [required_type]
end

function get_required_types(::UnionTreeNode, ::XSDStructModuleBuilderType)::Vector{String}

    # TODO: For now no checks are done for Unions

    return []
end

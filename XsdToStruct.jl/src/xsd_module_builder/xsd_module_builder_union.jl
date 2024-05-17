#! format: off

function write_node_specific(
    xsd_node::UnionTreeNode,
    xsd_module_builder::XSDStructModuleBuilderType,
    indent_level::Int
    )::Bool

    @debug "Writing as $(UnionTreeNode)"

    # write union types submodule
    undefined_union_nodes = filter(
        union_node -> qualified_name(union_node) ∉ defined_node_names(xsd_module_builder), xsd_node.union_nodes)

    if !isempty(undefined_union_nodes)
        write_child_submodule(
            sub_module_name(name(xsd_node)),
            undefined_union_nodes,
            xsd_module_builder,
            indent_level=indent_level)
    end

    write_docstring(xsd_node, xsd_module_builder, indent_level)
    write_union(xsd_node, xsd_module_builder, indent_level)

    push!(xsd_module_builder.defined_nodes, xsd_node)

    return true

end

function write_union(xsd_node::UnionTreeNode,
    xsd_module_builder::XSDStructModuleBuilderType,
    indent_level::Int
)

    type_name::AbstractString = name(xsd_node)
    union_names::Vector{<:AbstractString} = map(
        name -> sub_module_name(type_name)*"."*name, name.(xsd_node.union_nodes))
    union_string = xml_union_string(type_name, union_names)
    writeln(xsd_module_builder, IOStruct, union_string, indent_level=indent_level)

end

function xml_union_string(type_name::String, union_names::Vector{<:AbstractString})
union_list = "$(join(union_names, ", "))"

xml = """
Base.@kwdef struct $type_name <: $ABSTRACT_TYPE_PACKAGE.AbstractXSDUnion
    value :: Union{$union_list}
    __validated::Bool = true
end

$ABSTRACT_TYPE_PACKAGE.union_types(::Type{<:$type_name}) = ($union_list)
"""
return xml
end

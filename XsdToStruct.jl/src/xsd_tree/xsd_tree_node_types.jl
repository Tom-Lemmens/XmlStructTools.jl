
abstract type AbstractTreeNode end

Base.@kwdef struct CommonNodeData
    name::AbstractString
    sub_module::Union{Nothing,String} = nothing
    attributes::OptionalDictStringString = nothing
    docstring::Union{Nothing,String} = nothing
end

is_boolean(node::AbstractTreeNode)::Bool = false
name(node::AbstractTreeNode)::String = node.common_data.name
attributes(node::AbstractTreeNode) = node.common_data.attributes
xsd_docstring(node::AbstractTreeNode) = node.common_data.docstring
qualified_name(node::AbstractTreeNode)::String = qualified_name(node.common_data)
qualified_name(data::CommonNodeData)::String =
    isnothing(data.sub_module) ? data.name : data.sub_module * "." * data.name
xsd_restrictions(::AbstractTreeNode)::Nothing = nothing

Base.@kwdef struct SimpleTreeNode <: AbstractTreeNode
    common_data::CommonNodeData
    field::FieldData
    restrictions::OptionalDictStringString = nothing
end

xsd_restrictions(node::SimpleTreeNode)::OptionalDictStringString = node.restrictions

is_boolean(node::SimpleTreeNode)::Bool = node.field.julia_type == "Bool"

Base.@kwdef struct ComplexTreeNode <: AbstractTreeNode
    common_data::CommonNodeData
    fields::Vector{AbstractFieldData} = Vector{AbstractFieldData}()
    child_nodes::Vector{AbstractTreeNode} = Vector{AbstractTreeNode}()
    child_fields::Vector{FieldData} = Vector{FieldData}()
    field_ordering::Vector{<:AbstractString} = String[]
end

function get_all_fields(complex_node::ComplexTreeNode)
    all_fields = vcat(complex_node.fields, complex_node.child_fields)
    if isempty(all_fields)
        sorted_fields = all_fields
    else
        field_sorting = [findfirst(==(field.name), complex_node.field_ordering) for field in all_fields]
        sorted_fields = all_fields[invperm(field_sorting)]
    end
    return sorted_fields
end
function get_all_fields_of_type(complex_node::ComplexTreeNode, ::Type{T}) where {T<:AbstractFieldData}
    return Vector{T}(filter(x -> typeof(x) == T, get_all_fields(complex_node)))
end
function get_fields_of_type(complex_node::ComplexTreeNode, ::Type{T}) where {T<:AbstractFieldData}
    return Vector{T}(filter(x -> typeof(x) == T, complex_node.fields))
end
has_group_nodes(complex_node::ComplexTreeNode) = !isempty(complex_node.group_nodes)
has_child_nodes(complex_node::ComplexTreeNode) = !isempty(complex_node.child_nodes)

# https://www.w3.org/TR/xmlschema-2/#derivation-by-union
Base.@kwdef struct UnionTreeNode <: AbstractTreeNode
    common_data::CommonNodeData
    union_nodes::Vector{AbstractTreeNode} = Vector{AbstractTreeNode}()
end

Base.@kwdef struct ExtensionTreeNode <: AbstractTreeNode
    common_data::CommonNodeData
    node_content::ComplexTreeNode
    base_name::String
    base_children::Vector{AbstractTreeNode} = Vector{AbstractTreeNode}()
    base_child_fields::Vector{FieldData} = Vector{FieldData}()
    base_fields::Vector{AbstractFieldData} = Vector{AbstractFieldData}()
    base_field_ordering::Vector{<:AbstractString} = String[]
end

function get_all_fields(extension_node::ExtensionTreeNode)
    all_fields = vcat(extension_node.base_fields, extension_node.base_child_fields)
    if isempty(all_fields)
        sorted_fields = all_fields
    else
        field_sorting = [findfirst(==(field.name), extension_node.base_field_ordering) for field in all_fields]
        sorted_fields = all_fields[invperm(field_sorting)]
    end
    return sorted_fields
end

function get_all_non_child_fields(complex_node::ComplexTreeNode)::Vector{AbstractFieldData}
    # regular fields unrelated to a choice field
    non_choice_fields = get_fields_of_type(complex_node, FieldData)

    # fields from choices
    choice_fields =
        collect(Iterators.flatten(getproperty.(get_fields_of_type(complex_node, ChoiceFieldData), :choice_options)))

    return vcat(non_choice_fields, choice_fields)
end

"""
    required_julia_types(complex_node::ComplexTreeNode)::Vector{String}

Returns types which need to be defined in order for the struct definition of 'complex_node' to be valid.
"""
required_julia_types(complex_node::ComplexTreeNode)::Vector{String} =
    unique(qualified_type.(get_all_non_child_fields(complex_node)))

Base.@kwdef struct SchemaTreeNode <: AbstractTreeNode
    common_data::CommonNodeData
    root_field::FieldData
    has_simple_nodes::Bool
    has_complex_nodes::Bool
    requires_TimeZones::Bool
    group_nodes::Vector{ComplexTreeNode} = Vector{ComplexTreeNode}()
    child_nodes::Vector{AbstractTreeNode} = Vector{AbstractTreeNode}()
end

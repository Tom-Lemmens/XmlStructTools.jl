
abstract type AbstractFieldData end

has_datetime(field::AbstractFieldData)::Bool = false

const OptionalDictStringString = Union{Nothing,Dict{<:AbstractString,<:AbstractString}}

Base.@kwdef mutable struct FieldData <: AbstractFieldData
    name::String
    xsd_type::String
    julia_type::String = parse_xsd_type_to_julia_type(xsd_type)
    xsd_attributes::OptionalDictStringString = nothing
    sub_module::Union{Nothing,AbstractString} = nothing
    is_vector::Bool = is_vector(xsd_attributes)
    base_default_value = get_default_value(xsd_attributes)
    can_be_missing = can_be_missing(xsd_attributes)
end

has_datetime(field::FieldData)::Bool = field.xsd_type == "dateTime"

Base.@kwdef mutable struct ChoiceFieldData <: AbstractFieldData
    name::String
    choice_options::Vector{FieldData}
    julia_type::String = choice_julia_type(choice_options)
    xsd_attributes::OptionalDictStringString = nothing
    sub_module::Union{Nothing,AbstractString} = nothing
    is_vector::Bool = is_vector(xsd_attributes)
    base_default_value = get_default_value(xsd_attributes)
    can_be_missing = can_be_missing(xsd_attributes)
end

Base.@kwdef mutable struct GroupFieldData <: AbstractFieldData
    name::String
    xsd_attributes::OptionalDictStringString = nothing
end

function has_datetime(field::ChoiceFieldData)::Bool
    has_datetime = false

    for choice in field.choice_options
        has_datetime = choice.xsd_type == "dateTime"

        if has_datetime
            # we already found a matching node stop looking
            break
        end
    end

    return has_datetime
end

"""
    qualified_type(
        field_data::Union{FieldData, ChoiceFieldData}
    )::String

Return the qualified type name for the given field_data as read from the xsd.
This will include the xsd namespace explicitly if it was given in the xsd.
If the qualified name relative to the xsd namespace is needed add the xsd namespace as a string as the second
argument.
"""
function qualified_type(field_data::Union{FieldData,ChoiceFieldData})::String

    # not specified or edge case
    if isnothing(field_data.sub_module)
        qualified_type = field_data.julia_type
    else
        qualified_type = "$(field_data.sub_module).$(field_data.julia_type)"
    end

    return qualified_type
end

"""
    qualified_type(
        field_data::Union{FieldData, ChoiceFieldData},
        xsd_namespace::AbstractString
    )::String

Return the qualified type name for the given field_data relative to the namespace defined by the xsd.
Hence if any leading xsd namespace part is present in the qualified type name it will be removed.
"""
function qualified_type(field_data::Union{FieldData,ChoiceFieldData}, xsd_namespace::AbstractString)::String

    # not specified or edge case
    if isnothing(field_data.sub_module) || endswith(field_data.sub_module, xsd_namespace)
        qualified_type = field_data.julia_type
    else
        # find occurrence of xsd namespace in module
        sub_module_split = split(field_data.sub_module, ".")
        xsd_namespace_ind = findlast(x -> x == xsd_namespace, sub_module_split)

        if isnothing(xsd_namespace_ind)
            qualified_type = "$(field_data.sub_module).$(field_data.julia_type)"
        else
            # rewrite qualified submodule to be relative to the xsd namespace
            qualified_sub_module = join(sub_module_split[(xsd_namespace_ind + 1):end], ".")

            qualified_type = "$(qualified_sub_module).$(field_data.julia_type)"
        end
    end

    return qualified_type
end

"""
    qualified_type(field_data::GroupFieldData)::String

An Xsd group does not really have a qualified name, hence just the name is returned
"""
qualified_type(field_data::GroupFieldData)::String = field_data.name

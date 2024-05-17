
optional_type_string(type_string::AbstractString)::String = "Union{$type_string, Nothing}"

named_tuple_field_names(field_data_vector::Vector{AbstractFieldData})::String =
    join([":" * field_data.name for field_data in field_data_vector], ", ")

named_tuple_field_types(field_data_vector::Vector{AbstractFieldData})::String =
    join(optional_type_string.(qualified_type.(field_data_vector)), ", ")

function choice_julia_type(field_data_vector::Vector{AbstractFieldData})::String
    field_names = named_tuple_field_names(field_data_vector)
    field_types = named_tuple_field_types(field_data_vector)
    return "NamedTuple{($field_names), Tuple{$field_types}}"
end

# TODO: Better match for decimal?
const built_in_data_type_dict = Dict([
    ("string", "String"),
    ("double", "Float64"),
    ("boolean", "Bool"),
    ("dateTime", "Union{ZonedDateTime, DateTime}"),
    ("integer", "Int64"),
    ("int", "Int64"),
    ("nonNegativeInteger", "UInt64"),
    ("positiveInteger", "UInt64"),
    ("decimal", "Float64"),
])
get_julia_type(type_name::AbstractString)::String = get(built_in_data_type_dict, type_name, type_name)

# TODO:for now ignore namespace stuff
parse_xsd_type_to_julia_type(type_string::AbstractString)::String = get_julia_type(split(type_string, ":")[end])

# determine type properties from the given xsd attribute dictionary
function is_vector(xsd_attributes::OptionalDictStringString)::Bool
    if !isnothing(xsd_attributes) && haskey(xsd_attributes, "maxOccurs")
        max_occurs = xsd_attributes["maxOccurs"]
        is_vector = (max_occurs == "unbounded" || parse(Int, max_occurs) > 1)
    else
        is_vector = false
    end

    return is_vector
end

(
    get_default_value(xsd_attributes::OptionalDictStringString)::Union{Nothing,Any} =
        return !isnothing(xsd_attributes) && haskey(xsd_attributes, "default") ? xsd_attributes["default"] : nothing
)

function can_be_missing(xsd_attributes::OptionalDictStringString)::Bool
    return (!isnothing(xsd_attributes) && haskey(xsd_attributes, "minOccurs") && xsd_attributes["minOccurs"] == "0")
end

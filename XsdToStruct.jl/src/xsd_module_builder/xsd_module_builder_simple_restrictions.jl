#! format: off

const TOTAL_DIGITS_KEY = "totalDigits"
const FRACTION_DIGITS_KEY = "fractionDigits"
const MAX_INCLUSIVE_KEY = "maxInclusive"
const MAX_EXCLUSIVE_KEY = "maxExclusive"
const MIN_INCLUSIVE_KEY = "minInclusive"
const MIN_EXCLUSIVE_KEY = "minExclusive"

function write_restriction_functions(
	xsd_node::SimpleTreeNode,
	xsd_module_builder::XSDStructModuleBuilderType;
	indent_level::Int = 1,
)::Nothing
	restrictions_set = Set{String}()

	if haskey(xsd_node.restrictions, MAX_INCLUSIVE_KEY)
		write_max_inclusive(xsd_node, xsd_module_builder; indent_level = indent_level)
		push!(restrictions_set, "bound_restriction_check")
	elseif haskey(xsd_node.restrictions, MAX_EXCLUSIVE_KEY)
		write_max_exclusive(xsd_node, xsd_module_builder; indent_level = indent_level)
		push!(restrictions_set, "bound_restriction_check")
	end

	if haskey(xsd_node.restrictions, MIN_INCLUSIVE_KEY)
		write_min_inclusive(xsd_node, xsd_module_builder; indent_level = indent_level)
		push!(restrictions_set, "bound_restriction_check")
	elseif haskey(xsd_node.restrictions, MIN_EXCLUSIVE_KEY)
		write_min_exclusive(xsd_node, xsd_module_builder; indent_level = indent_level)
		push!(restrictions_set, "bound_restriction_check")
	end

	if haskey(xsd_node.restrictions, FRACTION_DIGITS_KEY)
		write_get_max_fraction_digits(xsd_node, xsd_module_builder; indent_level = indent_level)
		push!(restrictions_set, "fraction_digits_check")
	end

	if haskey(xsd_node.restrictions, TOTAL_DIGITS_KEY)
		write_get_max_total_digits(xsd_node, xsd_module_builder; indent_level = indent_level)
		push!(restrictions_set, "total_digits_check")
	end

	restrictions_vector = collect(restrictions_set)
	if !isempty(restrictions_vector)
		write_get_restriction_checks(
			xsd_node,
			restrictions_vector,
			xsd_module_builder,
			indent_level = indent_level)
	end

	return nothing
end

function get_value_string(julia_type_string::AbstractString, xsd_value_string::AbstractString)::String
	if julia_type_string in values(built_in_data_type_dict)
		julia_type = julia_type_string |> Meta.parse |> eval
		value_string = string(parse(julia_type, xsd_value_string))
	else
		value_string = julia_type_string * "($xsd_value_string)"
	end
	return value_string
end

function write_max_inclusive(
	xsd_node::SimpleTreeNode,
	xsd_module_builder::XSDStructModuleBuilderType;
	indent_level::Int = 1,
)::Nothing

	struct_name = name(xsd_node)
	julia_type_string = xsd_node.field.julia_type
	value_string = get_value_string(julia_type_string, xsd_node.restrictions[MAX_INCLUSIVE_KEY])

	max_inclusive_string = """
	@inline AbstractXsdTypes.get_max_value(::Type{$struct_name})::$julia_type_string = $value_string

	@inline AbstractXsdTypes.is_max_exclusive(::Type{$struct_name})::Bool = false
	"""

	writeln(
		xsd_module_builder,
		IOStruct,
		max_inclusive_string,
		indent_level = indent_level)

	return nothing
end

function write_max_exclusive(
	xsd_node::SimpleTreeNode,
	xsd_module_builder::XSDStructModuleBuilderType;
	indent_level::Int = 1,
)::Nothing

	struct_name = name(xsd_node)
	julia_type_string = xsd_node.field.julia_type
	value_string = get_value_string(julia_type_string, xsd_node.restrictions[MAX_EXCLUSIVE_KEY])

	max_inclusive_string = """
	@inline AbstractXsdTypes.get_max_value(::Type{$struct_name})::$julia_type_string = $value_string

	@inline AbstractXsdTypes.is_max_exclusive(::Type{$struct_name})::Bool = true
	"""

	writeln(
		xsd_module_builder,
		IOStruct,
		max_inclusive_string,
		indent_level = indent_level)

	return nothing
end

function write_min_inclusive(
	xsd_node::SimpleTreeNode,
	xsd_module_builder::XSDStructModuleBuilderType;
	indent_level::Int = 1,
)::Nothing

	struct_name = name(xsd_node)
	julia_type_string = xsd_node.field.julia_type
	value_string = get_value_string(julia_type_string, xsd_node.restrictions[MIN_INCLUSIVE_KEY])

	min_inclusive_string = """
	@inline AbstractXsdTypes.get_min_value(::Type{$struct_name})::$julia_type_string = $value_string

	@inline AbstractXsdTypes.is_min_exclusive(::Type{$struct_name})::Bool = false
	"""

	writeln(
		xsd_module_builder,
		IOStruct,
		min_inclusive_string,
		indent_level = indent_level)

	return nothing
end

function write_min_exclusive(
	xsd_node::SimpleTreeNode,
	xsd_module_builder::XSDStructModuleBuilderType;
	indent_level::Int = 1,
)::Nothing

	struct_name = name(xsd_node)
	julia_type_string = xsd_node.field.julia_type
	value_string = get_value_string(julia_type_string, xsd_node.restrictions[MIN_EXCLUSIVE_KEY])

	min_inclusive_string = """
	@inline AbstractXsdTypes.get_min_value(::Type{$struct_name})::$julia_type_string = $value_string

	@inline AbstractXsdTypes.is_min_exclusive(::Type{$struct_name})::Bool = true
	"""

	writeln(
		xsd_module_builder,
		IOStruct,
		min_inclusive_string,
		indent_level = indent_level)

	return nothing
end

function write_get_max_fraction_digits(
	xsd_node::SimpleTreeNode,
	xsd_module_builder::XSDStructModuleBuilderType;
	indent_level::Int = 1,
)::Nothing

	struct_name = name(xsd_node)
	digits_string = xsd_node.restrictions[FRACTION_DIGITS_KEY]

	max_digits_string = """@inline AbstractXsdTypes.get_max_fraction_digits(::Type{$struct_name})::Int = $digits_string"""

	write(
		xsd_module_builder,
		IOStruct,
		max_digits_string,
		indent_level = indent_level)

	write(
		xsd_module_builder,
		IOStruct,
		"\n\n",
		indent_level = indent_level)

	return nothing
end

function write_get_max_total_digits(
	xsd_node::SimpleTreeNode,
	xsd_module_builder::XSDStructModuleBuilderType;
	indent_level::Int = 1,
)::Nothing

	struct_name = name(xsd_node)
	digits_string = xsd_node.restrictions[TOTAL_DIGITS_KEY]

	max_digits_string = """@inline AbstractXsdTypes.get_max_total_digits(::Type{$struct_name})::Int = $digits_string"""

	write(
		xsd_module_builder,
		IOStruct,
		max_digits_string,
		indent_level = indent_level)

	write(
		xsd_module_builder,
		IOStruct,
		"\n\n",
		indent_level = indent_level)

	return nothing
end

function write_get_restriction_checks(
	xsd_node::SimpleTreeNode,
	restrictions::AbstractVector{<:AbstractString},
	xsd_module_builder::XSDStructModuleBuilderType;
	indent_level::Int = 1,
)::Nothing
	struct_name = name(xsd_node)

	signature_string = "@inline AbstractXsdTypes.get_restriction_checks(::Type{$struct_name}) = ("
	restrictions_string = join(["AbstractXsdTypes.$restriction," for restriction in restrictions], " ")*")"

	writeln(xsd_module_builder, IOStruct, signature_string, indent_level = indent_level)
	writeln(xsd_module_builder, IOStruct, restrictions_string, indent_level = indent_level+1)
	write(xsd_module_builder,IOStruct,"\n")

	return nothing
end

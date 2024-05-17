#! format: off

include("xsd_module_builder_simple_restrictions.jl")

function write_node_specific(
	xsd_node::SimpleTreeNode,
	xsd_module_builder::XSDStructModuleBuilderType,
	indent_level::Int = 1,
)::Bool

	@debug "Writing as $(SimpleTreeNode)"

	write_docstring(xsd_node, xsd_module_builder, indent_level)

	super_type = get_simple_node_super_type(xsd_node.field.julia_type, xsd_module_builder)

	writeln(
		xsd_module_builder,
		IOStruct,
		struct_line_string(name(xsd_node), super_type),
		indent_level = indent_level)

	if xsd_node.field.julia_type == "String"
		writeln(
			xsd_module_builder, IOStruct, "value::$(xsd_node.field.julia_type)", indent_level = indent_level + 1)
	else
		writeln(
			xsd_module_builder, IOStruct, "value::$(xsd_node.field.julia_type)", indent_level = indent_level + 1)
	end

	writeln(xsd_module_builder, IOStruct,
		"__xml_attributes::Union{Nothing, Dict{String, String}} = nothing"; indent_level = indent_level + 1)
	writeln(xsd_module_builder, IOStruct,
		"__validated::Bool = true"; indent_level = indent_level + 1)

    has_restrictions = !isnothing(xsd_node.restrictions) && !isempty(xsd_node.restrictions)

	if has_restrictions
		write_inner_constructor(xsd_node, xsd_module_builder; indent_level = indent_level + 1)
	end

	write(xsd_module_builder, IOStruct, "end\n\n", indent_level = indent_level)

	if has_restrictions
		write_restriction_functions(xsd_node, xsd_module_builder; indent_level = indent_level)
	end

	if super_type == AbstractString
		print_string_methods(xsd_module_builder, name(xsd_node), indent_level = indent_level)
	end

	push!(xsd_module_builder.defined_nodes, xsd_node)

	return true
end

const xsd_abstract_type_map = Dict((
	AbstractFloat => "$ABSTRACT_TYPE_PACKAGE.AbstractXSDFloat",
	Signed => "$ABSTRACT_TYPE_PACKAGE.AbstractXSDSigned",
	Unsigned => "$ABSTRACT_TYPE_PACKAGE.AbstractXSDUnsigned",
	AbstractString => "$ABSTRACT_TYPE_PACKAGE.AbstractXSDString"))

function get_supertype(type_string::AbstractString)
	if type_string == "Union{ZonedDateTime, DateTime}"
		supertype_value = Dates.AbstractDateTime
	else
		supertype_value = supertype(eval(Symbol(type_string)))
	end
	return supertype_value
end

const built_in_super_types = Dict(val => get_supertype(val) for val in values(built_in_data_type_dict))

function get_simple_node_super_type(type_name::AbstractString, xsd_module_builder::XSDStructModuleBuilderType)::String

	if type_name in keys(built_in_super_types)
		built_in_super_type = built_in_super_types[type_name]
		super_type = xsd_abstract_type_map[built_in_super_type]
	else
		base_simple_node = first(filter(x -> name(x) == type_name, get_defined_simple_nodes(xsd_module_builder)))
		super_type = get_simple_node_super_type(base_simple_node.field.julia_type, xsd_module_builder)
	end

	return super_type

end

function print_string_methods(
	xsd_module_builder::XSDStructModuleBuilderType, type_name::AbstractString; indent_level::Int)

	writeln(
		xsd_module_builder,
		IOStruct,
		"Base.ncodeunits(s::$(type_name)) = ncodeunits(s.value)",
		indent_level = indent_level)
	writeln(
		xsd_module_builder,
		IOStruct,
		"Base.iterate(s::$(type_name), i::Integer) = iterate(s.value, i)",
		indent_level = indent_level)
	writeln(
		xsd_module_builder,
		IOStruct,
		"Base.iterate(s::$(type_name)) = iterate(s.value)",
		indent_level = indent_level)

	write(xsd_module_builder, IOStruct, "\n", indent_level = indent_level)

end

const JULIA_SUPER_TYPES = Dict(
    "String" => "AbstractString",
    "Float64" => "Number",
    "Bool" => "Bool",
    "Union{ZonedDateTime, DateTime}" => "Dates.AbstractDateTime",
    "Int64" => "Number",
    "UInt64" => "Number",
    "AbstractXsdTypes.AbstractXSDString" => "AbstractString",
    "AbstractXsdTypes.AbstractXSDFloat" => "Number",
    "AbstractXsdTypes.AbstractXSDSigned" => "Number",
    "AbstractXsdTypes.AbstractXSDUnsigned" => "Number",
)
function write_inner_constructor(
	xsd_node::SimpleTreeNode,
	xsd_module_builder::XSDStructModuleBuilderType;
	indent_level::Int = 1,
)::Nothing

	struct_name = name(xsd_node)
    julia_type_string = xsd_node.field.julia_type
    if haskey(JULIA_SUPER_TYPES, julia_type_string)
        super_type = JULIA_SUPER_TYPES[julia_type_string]
    else
        xsd_super_type = get_simple_node_super_type(julia_type_string, xsd_module_builder)
        super_type = JULIA_SUPER_TYPES[xsd_super_type]
    end

	inner_constructor_string = """
function $struct_name(
    value::$super_type,
    __xml_attributes::Union{Nothing, Dict{String, String}}=nothing,
    __validated::Bool=true)
    if __validated
        AbstractXsdTypes.check_restrictions($struct_name, value)
    end
    return new(value, __xml_attributes, __validated)
end
"""

	write(
		xsd_module_builder,
		IOStruct,
		inner_constructor_string,
		indent_level = indent_level)

	return nothing
end


Base.@kwdef struct XSDStructModuleBuilderType
    xsd_filename::AbstractString
    xsd_tree::SchemaTreeNode
    io_top::IO
    io_struct::IO
    module_name::AbstractString = xsd_tree.common_data.name
    module_name_struct::AbstractString = module_name * "_struct"
    indent_string::AbstractString
    defined_nodes::Vector{AbstractTreeNode} = Vector{AbstractTreeNode}()
    skipped_nodes::Vector{AbstractTreeNode} = Vector{AbstractTreeNode}()
end

abstract type AbstractIOOption end
struct IOTop <: AbstractIOOption end
struct IOStruct <: AbstractIOOption end

function io_file_name(io::IOStream)::String
    return basename(last(split(strip(io.name, ['<', '>']), " ")))
end

io_file_name(xsd_module_builder::XSDStructModuleBuilderType, ::Type{IOTop})::String =
    io_file_name(xsd_module_builder.io_top)
io_file_name(xsd_module_builder::XSDStructModuleBuilderType, ::Type{IOStruct})::String =
    io_file_name(xsd_module_builder.io_struct)

# TODO: add indent at every \n, but not all....

const NEWLINE_CHAR = '\n'
function generate_indented_string(
    xsd_module_builder::XSDStructModuleBuilderType,
    string_to_write::AbstractString,
    indent_level::Integer,
)::String
    split_string = split(string_to_write, NEWLINE_CHAR)
    indented_split_string = map(split_string) do sub_string
        # stripped_string = lstrip(sub_string)  # remove leading whitespace, indent will be off if not stripped
        return isempty(sub_string) ? sub_string : (xsd_module_builder.indent_string^indent_level * sub_string)
    end
    indented_string = join(indented_split_string, NEWLINE_CHAR)
    return indented_string
end

function write(
    xsd_module_builder::XSDStructModuleBuilderType,
    ::Type{IOTop},
    string_to_write::AbstractString = "";
    indent_level::Integer = 0,
)::Nothing
    indented_string = generate_indented_string(xsd_module_builder, string_to_write, indent_level)
    return print(xsd_module_builder.io_top, indented_string)
end

function writeln(
    xsd_module_builder::XSDStructModuleBuilderType,
    ::Type{IOTop},
    string_to_write::AbstractString = "";
    indent_level::Integer = 0,
)::Nothing
    indented_string = generate_indented_string(xsd_module_builder, string_to_write, indent_level)
    return println(xsd_module_builder.io_top, indented_string)
end

function write(
    xsd_module_builder::XSDStructModuleBuilderType,
    ::Type{IOStruct},
    string_to_write::AbstractString = "";
    indent_level::Integer = 0,
)::Nothing
    indented_string = generate_indented_string(xsd_module_builder, string_to_write, indent_level)
    return print(xsd_module_builder.io_struct, indented_string)
end

function writeln(
    xsd_module_builder::XSDStructModuleBuilderType,
    ::Type{IOStruct},
    string_to_write::AbstractString = "";
    indent_level::Integer = 0,
)::Nothing
    indented_string = generate_indented_string(xsd_module_builder, string_to_write, indent_level)
    return println(xsd_module_builder.io_struct, indented_string)
end

defined_node_names(xsd_module_builder::XSDStructModuleBuilderType)::Vector{String} =
    qualified_name.(xsd_module_builder.defined_nodes)
skipped_node_names(xsd_module_builder::XSDStructModuleBuilderType)::Vector{String} =
    qualified_name.(xsd_module_builder.skipped_nodes)
get_defined_simple_nodes(xsd_module_builder::XSDStructModuleBuilderType)::Vector{SimpleTreeNode} =
    filter(x -> x isa SimpleTreeNode, xsd_module_builder.defined_nodes)

function is_based_on_string(field_data::AbstractFieldData, xsd_module_builder::XSDStructModuleBuilderType)::Bool
    matching_defined_simple_nodes =
        filter(x -> name(x) == field_data.julia_type, get_defined_simple_nodes(xsd_module_builder))

    if isempty(matching_defined_simple_nodes)
        return false
    else
        matching_simple_node = first(matching_defined_simple_nodes)  # should only be one match
        simple_node_supertype = get_simple_node_super_type(matching_simple_node.field.julia_type, xsd_module_builder)
        return simple_node_supertype == "$ABSTRACT_TYPE_PACKAGE.AbstractXSDString"
    end
end

is_defined(type_name::AbstractString, xsd_module_builder::XSDStructModuleBuilderType)::Bool = (
    ((split(type_name, ".") |> last) in values(built_in_data_type_dict)) ||
    (type_name in defined_node_names(xsd_module_builder))
)

function struct_line_string(struct_name::AbstractString; kwdef::Bool = true)::String
    struct_line = "struct $(struct_name)"
    if kwdef
        struct_line = "Base.@kwdef " * struct_line
    end
    return struct_line
end
function struct_line_string(struct_name::AbstractString, supertype; kwdef::Bool = true)::String
    struct_line = "struct $(struct_name) <: $(supertype)"
    if kwdef
        struct_line = "Base.@kwdef " * struct_line
    end
    return struct_line
end

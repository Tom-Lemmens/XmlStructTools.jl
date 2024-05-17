
include("xsd_module_builder_simple.jl")
include("xsd_module_builder_union.jl")

function write_struct_module_to_io(xsd_module_builder::XSDStructModuleBuilderType)::Nothing
    print(xsd_module_builder.io_struct, "module $(xsd_module_builder.module_name_struct)\n\n")

    if xsd_module_builder.xsd_tree.requires_TimeZones
        print(xsd_module_builder.io_struct, "using Reexport\n")
        print(xsd_module_builder.io_struct, "@reexport using Dates\n")
        print(xsd_module_builder.io_struct, "@reexport using TimeZones\n")
    end

    writeln(xsd_module_builder, IOStruct, "import $ABSTRACT_TYPE_PACKAGE")
    write(xsd_module_builder, IOStruct, "\n")

    # first pass
    for child_node in xsd_module_builder.xsd_tree.child_nodes
        write_node(child_node, xsd_module_builder)
    end

    @debug "Defined node names:\n$(defined_node_names(xsd_module_builder))"
    @debug "Skipped node names:\n$(skipped_node_names(xsd_module_builder))"

    # loop skipped until done
    loops = 0
    previous_missing_nodes = length(xsd_module_builder.skipped_nodes)
    while previous_missing_nodes > 0
        skipped_nodes = copy(xsd_module_builder.skipped_nodes)
        resize!(xsd_module_builder.skipped_nodes, 0)
        for node in skipped_nodes
            write_node(node, xsd_module_builder)
        end

        loops += 1
        missing_nodes = length(xsd_module_builder.skipped_nodes)
        @info "Loops over skipped nodes =  $loops, $missing_nodes nodes still missing."

        @debug "Defined node names:\n$(defined_node_names(xsd_module_builder))"
        @debug "Skipped node names:\n$(skipped_node_names(xsd_module_builder))"

        if missing_nodes == previous_missing_nodes
            @warn "No more nodes defined with respect to previous loop, stopping the loop over missed nodes."
            @warn "Still missing:\n$(xsd_module_builder.skipped_nodes)"
            break
        elseif missing_nodes > previous_missing_nodes
            error(
                "Amount of missing nodes has increased from $previous_missing_nodes to $missing_nodes;" *
                "something is wrong, stopping here.",
            )
        end

        previous_missing_nodes = missing_nodes
    end

    println(xsd_module_builder.io_struct, "end")

    return nothing
end

function write_node_specific(
    xsd_node::ComplexTreeNode,
    xsd_module_builder::XSDStructModuleBuilderType,
    indent_level::Int,
)::Bool
    @debug "Writing as $(ComplexTreeNode)"

    undefined_child_nodes =
        filter(child_node -> qualified_name(child_node) ∉ defined_node_names(xsd_module_builder), xsd_node.child_nodes)

    if !isempty(undefined_child_nodes)
        write_child_submodule(
            sub_module_name(name(xsd_node)),
            undefined_child_nodes,
            xsd_module_builder,
            indent_level = indent_level,
        )
    end

    write_docstring(xsd_node, xsd_module_builder, indent_level)

    choice_fields = get_all_fields_of_type(xsd_node, ChoiceFieldData)

    if isempty(choice_fields)
        write_node_no_choice(xsd_node, xsd_module_builder, indent_level)
    else
        @debug "Found choice fields: $(getproperty.(choice_fields, :name))"
        write_node_with_choice(xsd_node, choice_fields, xsd_module_builder, indent_level)
    end

    return true
end

function write_child_submodule(
    sub_module_name::AbstractString,
    sub_module_nodes::Vector{AbstractTreeNode},
    xsd_module_builder::XSDStructModuleBuilderType;
    indent_level::Int,
)::Nothing
    @debug "Writing submodule $(sub_module_name) for nodes:\n$(name.(sub_module_nodes))"

    writeln(xsd_module_builder, IOStruct, "module $(sub_module_name)", indent_level = indent_level)

    write(xsd_module_builder, IOStruct, "\n")

    write(xsd_module_builder, IOStruct, "\n")

    writeln(xsd_module_builder, IOStruct, "import AbstractXsdTypes", indent_level = indent_level + 1)

    write(xsd_module_builder, IOStruct, "\n")

    writeln(
        xsd_module_builder,
        IOStruct,
        "using ..$(xsd_module_builder.module_name_struct)",
        indent_level = indent_level + 1,
    )

    write(xsd_module_builder, IOStruct, "\n")

    for node in sub_module_nodes
        write_node(node, xsd_module_builder, export_line = false, indent_level = indent_level + 1)
    end

    writeln(xsd_module_builder, IOStruct, "end", indent_level = indent_level)

    write(xsd_module_builder, IOStruct, "\n")

    writeln(xsd_module_builder, IOStruct, "export $(sub_module_name)", indent_level = indent_level)

    return write(xsd_module_builder, IOStruct, "\n")
end

function write_node_no_choice(
    xsd_node::ComplexTreeNode,
    xsd_module_builder::XSDStructModuleBuilderType,
    indent_level::Int,
)
    @debug "writing with no choice fields"

    writeln(
        xsd_module_builder,
        IOStruct,
        struct_line_string(name(xsd_node), "$ABSTRACT_TYPE_PACKAGE.AbstractXSDComplex"),
        indent_level = indent_level,
    )

    all_fields = get_all_fields(xsd_node)
    @debug "Writing fields: $(getproperty.(all_fields, :name))"

    for field in all_fields
        field_string = generate_field_string(field)
        writeln(xsd_module_builder, IOStruct, field_string, indent_level = indent_level + 1)
    end

    writeln(
        xsd_module_builder,
        IOStruct,
        "__xml_attributes::Union{Nothing, Dict{String, String}} = nothing";
        indent_level = indent_level + 1,
    )
    writeln(xsd_module_builder, IOStruct, "__validated::Bool = true"; indent_level = indent_level + 1)

    write(xsd_module_builder, IOStruct, "end\n\n", indent_level = indent_level)
    write_defaults_function(xsd_module_builder, name(xsd_node), all_fields, indent_level = indent_level)
    return push!(xsd_module_builder.defined_nodes, xsd_node)
end

function write_node_with_choice(
    xsd_node::ComplexTreeNode,
    choice_fields::Vector{ChoiceFieldData},
    xsd_module_builder::XSDStructModuleBuilderType,
    indent_level::Int,
)::Nothing
    @debug "writing with choice fields"

    field_strings = Vector{String}()

    writeln(
        xsd_module_builder,
        IOStruct,
        struct_line_string(name(xsd_node), "$ABSTRACT_TYPE_PACKAGE.AbstractXSDComplex", kwdef = false),
    )

    all_fields = get_all_fields(xsd_node)
    for field in all_fields
        field_string = generate_field_string(field)
        push!(field_strings, field_string)

        no_default_field_string = split(field_string, "=") |> first |> strip # remove default values
        writeln(xsd_module_builder, IOStruct, no_default_field_string, indent_level = indent_level + 1)
    end

    writeln(
        xsd_module_builder,
        IOStruct,
        "__xml_attributes::Union{Nothing, Dict{String, String}}";
        indent_level = indent_level + 1,
    )
    writeln(xsd_module_builder, IOStruct, "__validated::Bool"; indent_level = indent_level + 1)

    write(xsd_module_builder, IOStruct, "end\n\n", indent_level = indent_level)
    write_defaults_function(xsd_module_builder, name(xsd_node), all_fields, indent_level = indent_level)
    push!(xsd_module_builder.defined_nodes, xsd_node)

    # Write additional method overrides for choice fields
    write_choice_outer_constructor(xsd_node, field_strings, choice_fields, xsd_module_builder, indent_level)
    writeln(xsd_module_builder, IOStruct)
    write_choice_properties(name(xsd_node), choice_fields, xsd_module_builder, indent_level)

    return nothing
end

function write_choice_outer_constructor(
    xsd_node::ComplexTreeNode,
    field_strings::Vector{String},
    choice_fields::Vector{ChoiceFieldData},
    xsd_module_builder::XSDStructModuleBuilderType,
    indent_level::Int,
)::Nothing

    # print function signature
    writeln(xsd_module_builder, IOStruct, "function $(name(xsd_node))(;", indent_level = indent_level)
    write(
        xsd_module_builder,
        IOStruct,
        join(inner_constructor_arguments(get_all_fields(xsd_node), field_strings), ",\n"),
        indent_level = indent_level + 1,
    )
    writeln(xsd_module_builder, IOStruct, ")", indent_level = indent_level)

    writeln(xsd_module_builder, IOStruct)

    # print checks for choice fields
    write_choice_checks(choice_fields, xsd_module_builder, indent_level)

    # print new call
    writeln(xsd_module_builder, IOStruct, "else", indent_level = indent_level + 1)

    constructor_arguments = constructor_arguments_string(get_all_fields(xsd_node))
    writeln(xsd_module_builder, IOStruct, "$(name(xsd_node))($constructor_arguments)", indent_level = indent_level + 2)

    writeln(xsd_module_builder, IOStruct, "end", indent_level = indent_level + 1)

    writeln(xsd_module_builder, IOStruct, "end", indent_level = indent_level)

    return
end

function inner_constructor_arguments(fields::Vector{AbstractFieldData}, field_strings::Vector{String})::Vector{String}
    string_vector = String[]
    for (field, field_string) in zip(fields, field_strings)
        if field isa ChoiceFieldData
            matches = eachmatch(r"(Union{[\w.]+, Nothing})+", field_string)
            for (sub_field, sub_field_match) in zip(field.choice_options, matches)
                print_string = "$(sub_field.name)::"
                print_string *= first(sub_field_match.captures)
                print_string *= "=nothing"

                push!(string_vector, print_string)
            end
        else
            push!(string_vector, field_string)
        end
    end

    # add extra __xml_attributes
    push!(string_vector, "__xml_attributes::Union{Nothing, Dict{<:AbstractString, <:AbstractString}} = nothing")

    # add extra __validated
    push!(string_vector, "__validated::Bool = true")

    return string_vector
end

function write_choice_checks(
    choice_fields::Vector{ChoiceFieldData},
    xsd_module_builder::XSDStructModuleBuilderType,
    indent_level::Int,
)::Nothing
    choice_fields_copy = deepcopy(choice_fields)
    choice_field = popfirst!(choice_fields_copy)
    choice_names = [choice.name for choice in choice_field.choice_options]

    writeln(
        xsd_module_builder,
        IOStruct,
        "if count(!isnothing, [$(join(choice_names, ", "))]) > 1",
        indent_level = indent_level + 1,
    )
    writeln(
        xsd_module_builder,
        IOStruct,
        "error(\"Only one of $(join(choice_names, " or ")) can be not nothing\")",
        indent_level = indent_level + 2,
    )

    while !isempty(choice_fields_copy)
        choice_field = popfirst!(choice_fields_copy)
        choice_names = [choice.name for choice in choice_field.choice_options]

        writeln(
            xsd_module_builder,
            IOStruct,
            "elseif count(!isnothing, [$(join(choice_names, ", "))]) > 1",
            indent_level = indent_level + 1,
        )

        writeln(
            xsd_module_builder,
            IOStruct,
            "error(\"Only one of $(join(choice_names, " or ")) can be not nothing\")",
            indent_level = indent_level + 2,
        )
    end

    return nothing
end

function constructor_arguments_string(fields::Vector{AbstractFieldData})::String
    call_arguments = String[]

    for field in fields
        if field isa ChoiceFieldData
            named_tuple_arguments = String[]
            for choice in field.choice_options
                push!(named_tuple_arguments, choice.name)
            end
            push!(call_arguments, "($(join(["$arg=$arg" for arg in named_tuple_arguments], ", ")))")
        else
            push!(call_arguments, field.name)
        end
    end

    # add extra __xml_attributes
    push!(call_arguments, "__xml_attributes")

    # add extra __validated
    push!(call_arguments, "__validated")

    return join(call_arguments, ", ")
end

function write_choice_properties(
    parent_name::AbstractString,
    choice_fields::Vector{ChoiceFieldData},
    xsd_module_builder::XSDStructModuleBuilderType,
    indent_level::Int,
)
    full_field_names_list =
        [":" * field.name for choice_field in choice_fields for field in choice_field.choice_options]

    writeln(
        xsd_module_builder,
        IOStruct,
        "Base.propertynames(x::$parent_name, private::Bool=false) = Tuple(append!(",
        indent_level = indent_level,
    )
    writeln(
        xsd_module_builder,
        IOStruct,
        "filter(s->!startswith(String(s), \"__$parent_name\"), collect(fieldnames($parent_name))),",
        indent_level = indent_level + 1,
    )
    writeln(xsd_module_builder, IOStruct, "[$(join(full_field_names_list, ", "))]))", indent_level = indent_level + 1)

    choice_fields_tmp = deepcopy(choice_fields)

    # start function
    writeln(
        xsd_module_builder,
        IOStruct,
        "function Base.getproperty(x::$parent_name, s::Symbol)",
        indent_level = indent_level,
    )

    # write first case
    current_field = popfirst!(choice_fields_tmp)
    current_field_choices = join([":" * field.name for field in current_field.choice_options], ", ")

    writeln(xsd_module_builder, IOStruct, "if s in [$current_field_choices]", indent_level = indent_level + 1)
    writeln(
        xsd_module_builder,
        IOStruct,
        "return getfield(getfield(x, Symbol(\"$(current_field.name)\")), s)",
        indent_level = indent_level + 2,
    )

    # write remaining cases
    while !isempty(choice_fields_tmp)
        current_field = popfirst!(choice_fields_tmp)
        current_field_choices = join([":" * field.name for field in current_field.choice_options], ", ")

        writeln(xsd_module_builder, IOStruct, "elseif s in [$current_field_choices]", indent_level = indent_level + 1)

        writeln(
            xsd_module_builder,
            IOStruct,
            "return getfield(getfield(x, Symbol(\"$(current_field.name)\")), s)",
            indent_level = indent_level + 2,
        )
    end

    # write fallback
    writeln(xsd_module_builder, IOStruct, "else", indent_level = indent_level + 1)

    writeln(xsd_module_builder, IOStruct, "return getfield(x, s)", indent_level = indent_level + 2)

    writeln(xsd_module_builder, IOStruct, "end", indent_level = indent_level + 1)

    # close function
    write(xsd_module_builder, IOStruct, "end", indent_level = indent_level)

    return write(xsd_module_builder, IOStruct, "\n\n")
end

# TODO: Change this to a version for FieldData and one for ChoiceFieldData!!!
function generate_field_string(field_data::AbstractFieldData)::String
    full_field_type = qualified_type(field_data)

    # handle Vector types
    if field_data.is_vector
        full_field_type = "Vector{$(full_field_type)}"
    end

    # handle minOccurs=0
    if field_data.can_be_missing
        full_field_type = "Union{Nothing, $(full_field_type)}"
        field_string = "$(field_data.name)::$(full_field_type) = nothing"
    else
        field_string = "$(field_data.name)::$(full_field_type)"
    end

    return field_string
end

function generate_defaults_string(
    field_data::AbstractFieldData,
    xsd_module_builder::XSDStructModuleBuilderType,
)::Union{Nothing,String}
    full_field_type = qualified_type(field_data)

    # handle default values
    default_value = field_data.base_default_value

    if !isnothing(default_value)
        # special case if julia_type is a String or based on a String since in this case we need extra "" marks
        if field_data.julia_type == "String" || is_based_on_string(field_data, xsd_module_builder)
            default_value = "\"$(default_value)\""
        end

        # wrap default value with appropriate constructor
        if field_data.julia_type == "Union{ZonedDateTime, DateTime}"
            defaults_value = construct_time_default_value(default_value)
        else
            defaults_value = "$(full_field_type)($(default_value))"
        end
        defaults_string = "$(field_data.name) = $defaults_value"
    else
        defaults_string = nothing
    end

    return defaults_string
end

# Regex inspired by section 3.2.7.3 Timezones of
# https://www.w3.org/TR/2004/REC-xmlschema-2-20041028/datatypes.html#dateTime
const timezone_regex = r"((\+|-)\d\d:\d\d)|Z"
function construct_time_default_value(default_value::AbstractString)::String
    timezone_match = match(timezone_regex, default_value)
    is_not_timezone_string = isnothing(timezone_match)
    if is_not_timezone_string
        defaults_value = "DateTime(\"$default_value\")"
    else
        defaults_value = "ZonedDateTime(\"$default_value\", \"yyyy-mm-ddTHH:MM:SSzzzzzz\")"
    end
end

function write_defaults_function(
    xsd_module_builder::XSDStructModuleBuilderType,
    struct_name::AbstractString,
    all_fields::Vector{AbstractFieldData};
    indent_level::Int,
)::Nothing
    function_signature = "AbstractXsdTypes.defaults(::Type{$struct_name})"

    default_strings = String[]

    for field_data in all_fields
        if !isnothing(field_data.base_default_value)
            field_string = generate_defaults_string(field_data, xsd_module_builder)
            isnothing(field_string) || push!(default_strings, field_string)
        end
    end

    if !isempty(default_strings)
        defaults_named_tuple = "(" * join(default_strings, ", ") * ", )"  # trailing , to ensure NamedTuple
        function_string = function_signature * " = " * defaults_named_tuple

        @debug "Writing defaults function: $function_string"
        writeln(xsd_module_builder, IOStruct, function_string, indent_level = indent_level)
        write(xsd_module_builder, IOStruct, "\n", indent_level = indent_level)
    end

    return nothing
end

function write_node_specific(
    xsd_node::ExtensionTreeNode,
    xsd_module_builder::XSDStructModuleBuilderType,
    indent_level::Int = 1,
)::Bool
    @debug "Writing as $(ExtensionTreeNode)"

    xsd_own_node = xsd_node.node_content

    # First write submodule child types for own content
    undefined_child_nodes = filter(
        child_node -> qualified_name(child_node) ∉ defined_node_names(xsd_module_builder),
        xsd_own_node.child_nodes,
    )

    if !isempty(undefined_child_nodes)
        write_child_submodule(
            sub_module_name(name(xsd_node)),
            undefined_child_nodes,
            xsd_module_builder,
            indent_level = indent_level,
        )
    end

    # construct temporary complex node and use this node to write the struct definition
    combined_fields = [xsd_node.base_fields; xsd_node.base_child_fields; get_all_fields(xsd_own_node)]
    combined_children = [xsd_node.base_children; xsd_own_node.child_nodes]
    combined_order = [xsd_node.base_field_ordering; xsd_own_node.field_ordering]

    tmp_node = ComplexTreeNode(
        common_data = xsd_node.common_data,
        fields = combined_fields,
        child_nodes = combined_children,
        field_ordering = combined_order,
    )

    choice_fields = get_all_fields_of_type(tmp_node, ChoiceFieldData)

    write_docstring(tmp_node, xsd_module_builder, indent_level)

    if isempty(choice_fields)
        write_node_no_choice(tmp_node, xsd_module_builder, indent_level)
    else
        write_node_with_choice(tmp_node, choice_fields, xsd_module_builder, indent_level)
    end

    return true
end

function write_node(
    xsd_node::AbstractTreeNode,
    xsd_module_builder::XSDStructModuleBuilderType;
    export_line::Bool = true,
    indent_level::Int = 0,
)::Nothing

    # nothing to do if already defined
    if qualified_name(xsd_node) in defined_node_names(xsd_module_builder)
        return nothing
    end

    if check_node_ready(xsd_node, xsd_module_builder)
        @debug "Begin writing struct $(name(xsd_node))"

        write_node_specific(xsd_node, xsd_module_builder, indent_level)

        if export_line
            write_export(xsd_node, xsd_module_builder, indent_level)
        end

        @debug "Finished writing struct $(name(xsd_node))"
    else
        @debug "Skipping node $xsd_node"

        push!(xsd_module_builder.skipped_nodes, xsd_node)
    end

    return nothing
end

function write_export(xsd_node::AbstractTreeNode, xsd_module_builder::XSDStructModuleBuilderType, indent_level::Int = 0)
    writeln(xsd_module_builder, IOStruct, "export $(name(xsd_node))", indent_level = indent_level)
    return write(xsd_module_builder, IOStruct, "\n")
end

function write_docstring(
    xsd_node::AbstractTreeNode,
    xsd_module_builder::XSDStructModuleBuilderType,
    indent_level::Int,
)::Nothing
    docstring = xsd_docstring(xsd_node)
    if !isnothing(docstring)
        writeln(xsd_module_builder, IOStruct, "\"\"\"", indent_level = indent_level)
        writeln(xsd_module_builder, IOStruct, docstring, indent_level = indent_level)
        writeln(xsd_module_builder, IOStruct, "\"\"\"", indent_level = indent_level)
    end

    return nothing
end

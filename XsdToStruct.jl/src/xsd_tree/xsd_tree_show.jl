
# struct for indentation settings
Base.@kwdef struct IndentSettings
    indent_string::Any
    indent::Any
end
name_indent_string(indent_settings::IndentSettings) = indent_settings.indent_string^indent_settings.indent
node_field_indent_string(indent_settings::IndentSettings) = indent_settings.indent_string^(indent_settings.indent + 1)
node_attribute_indent_string(indent_settings::IndentSettings) =
    indent_settings.indent_string^(indent_settings.indent + 2)

# functions for printing parts of specific types of nodes
print_specific_node(io::IO, indent_settings::IndentSettings, xsd_node::T) where {T<:AbstractTreeNode} = ""

function print_specific_node(io::IO, indent_settings::IndentSettings, xsd_node::SimpleTreeNode)
    println(io, "$(node_field_indent_string(indent_settings))Type: $(qualified_type(xsd_node.field))")

    # Print restrictions
    if !isnothing(xsd_node.restrictions)
        println(io, "$(node_field_indent_string(indent_settings))Restrictions:")
        println(io, "$(node_attribute_indent_string(indent_settings))$(xsd_node.restrictions)")
    end
end

function print_specific_node(io::IO, indent_settings::IndentSettings, xsd_node::ComplexTreeNode)
    # Print normal fields
    if !isempty(xsd_node.fields)
        println(io, "$(node_field_indent_string(indent_settings))Fields:")
        for field in xsd_node.fields
            println(io, "$(node_attribute_indent_string(indent_settings))$(field.name): $(qualified_type(field))")
        end
    end

    # Print child fields
    if !isempty(xsd_node.child_fields)
        println(io, "$(node_field_indent_string(indent_settings))Child fields:")
        for field in xsd_node.child_fields
            println(io, "$(node_attribute_indent_string(indent_settings))$(field.name): $(qualified_type(field))")
        end
    end

    # Recurse through children
    if !isempty(xsd_node.child_nodes)
        println(io, "$(node_field_indent_string(indent_settings))Children:")
        for child in xsd_node.child_nodes
            show(io, child, indent_settings.indent + 2)
        end
    end
end

function print_specific_node(io::IO, indent_settings::IndentSettings, xsd_node::ExtensionTreeNode)
    # Print base name
    println(io, "$(node_field_indent_string(indent_settings))Base name: $(xsd_node.base_name)")

    # Print base fields
    if !isempty(xsd_node.base_fields)
        println(io, "$(node_field_indent_string(indent_settings))Base fields:")
        for field in xsd_node.base_fields
            println(io, "$(node_attribute_indent_string(indent_settings))$(field.name): $(qualified_type(field))")
        end
    end

    # Print base child fields
    if !isempty(xsd_node.base_child_fields)
        println(io, "$(node_field_indent_string(indent_settings))Base child fields:")
        for field in xsd_node.base_child_fields
            println(io, "$(node_attribute_indent_string(indent_settings))$(field.name): $(qualified_type(field))")
        end
    end

    # Recurse through base children
    if !isempty(xsd_node.base_children)
        println(io, "$(node_field_indent_string(indent_settings))Base children:")
        for child in xsd_node.base_children
            show(io, child, indent_settings.indent + 2)
        end
    end

    # Print own content
    println(io, "$(node_field_indent_string(indent_settings))Extension:")
    return show(io, xsd_node.node_content, indent_settings.indent + 2)
end

function print_specific_node(io::IO, indent_settings::IndentSettings, xsd_node::SchemaTreeNode)
    println(io, "$(node_field_indent_string(indent_settings))Root node:")

    field_name = xsd_node.root_field.name
    field_type = qualified_type(xsd_node.root_field)
    println(io, "$(node_attribute_indent_string(indent_settings))$(field_name): $(field_type)")

    # Recurse through children
    if !isempty(xsd_node.child_nodes)
        println(io, "$(node_field_indent_string(indent_settings))Children:")
        for child in xsd_node.child_nodes
            show(io, child, indent_settings.indent + 2)
        end
    end
end

function print_common(io::IO, indent_settings::IndentSettings, xsd_node::T) where {T<:AbstractTreeNode}
    # Print name and type line
    println(io, "$(name_indent_string(indent_settings))$(qualified_name(xsd_node))::$(typeof(xsd_node))")

    # Print attributes
    if !isnothing(attributes(xsd_node))
        println(io, "$(node_field_indent_string(indent_settings))Attributes:")
        println(io, "$(node_attribute_indent_string(indent_settings))$(attributes(xsd_node))")
    end

    docstring = xsd_docstring(xsd_node)
    if !isnothing(docstring)
        println(io, "$(node_field_indent_string(indent_settings))Docstring:")
        println(io, "$(node_attribute_indent_string(indent_settings))$(docstring)")
    end
end

# override the show function for all node types
import Base.show
function show(io::IO, xsd_node::T, indent = 0) where {T<:AbstractTreeNode}

    # Indent strings for formatting purposes
    indent_settings = IndentSettings(indent_string = "|\t", indent = indent)

    # common print parts
    print_common(io, indent_settings, xsd_node)

    # node type specific print
    return print_specific_node(io, indent_settings, xsd_node)
end

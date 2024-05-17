
# Common functions for all simple types
Base.show(io::IO, x::AbstractXSDSimpleUnionTypes) = show(io, x.value)
Base.string(x::AbstractXSDSimpleUnionTypes) = string(x.value)

function Base.show(io::IO, x::Union{AbstractXSDComplex,Vector{<:AbstractXSDComplex}})::Nothing
    return print_tree(io, x)
end

function Base.show(io::IO, ::MIME"text/plain", x::Vector{<:AbstractXSDComplex})::Nothing
    return show(io, x)
end

function Base.show(io::IO, x::Vector{T})::Nothing where {T<:AbstractXSDComplex}
    return print(io, "$(length(x))-element Vector{$T}")
end

const base_indent_string = "|   "
const empty_indent_string = " "^length(base_indent_string)
const branch_string = "|-- "

"""
    print_treeprint_tree(
        io::IO,
        x::AbstractXSDComplex;
        print_all::Bool=false,
        indent_string::AbstractString=""
    )::Nothing

Prints the AbstractXSDComplex as a tree.
"""
function print_tree(io::IO, x::AbstractXSDComplex; print_all::Bool = false, indent_string::AbstractString = "")::Nothing
    properties = propertynames(x)
    n_properties = length(properties)

    prefix_string = indent_string * branch_string

    for (i, property) in enumerate(properties)
        if i == n_properties
            new_indent_string = indent_string * empty_indent_string
        else
            new_indent_string = indent_string * base_indent_string
        end

        property_value = getproperty(x, property)
        if property_value isa Union{AbstractXSDComplex,Vector{<:AbstractXSDComplex}}
            print(io, prefix_string * "$property:")
            if print_all
                println(io)
                print_tree(io, property_value; indent_string = new_indent_string, print_all = print_all)
            else
                println(io, " ...")
            end
        else
            println(io, prefix_string * "$property: $property_value")
        end
    end

    return nothing
end

function print_tree(
    io::IO,
    x::Vector{<:AbstractXSDComplex};
    print_all::Bool = false,
    indent_string::AbstractString = "",
)::Nothing
    for element in x
        print_tree(io, element; print_all = print_all, indent_string = indent_string)
    end

    return nothing
end

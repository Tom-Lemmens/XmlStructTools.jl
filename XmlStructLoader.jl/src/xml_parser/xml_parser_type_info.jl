"""
	(type_in_module(::Type{T}, module_ref::Module)::Bool) where T <: Any

Determine if given type T is defined in the module specified by module_symbol, i.e. whether T is one
of the schema-generated structs (possibly nested in a submodule, e.g. a choice/union "Types" submodule)
rather than a base/stdlib type like String or Float64.

Walks T's module ancestry looking for module_ref, rather than checking name membership via
`ccall(:jl_module_names, ...)`: that approach returned every name reachable via the module's
`@reexport using` statements (including Base/stdlib names like `String`) on modern Julia, not just the
module's own defined types, misrouting base-typed fields into the custom-struct parsing path.
"""
function type_in_module(@nospecialize(T::Type), module_ref::Module)::Bool
    # An unrestricted xs:dateTime field's julia_type is the literal Union{ZonedDateTime,DateTime}
    # (built_in_data_type_dict), not a single concrete type - parentmodule() doesn't accept a
    # Union at all, and a Union of stdlib alternatives is never a single user-generated struct
    # type regardless, so short-circuit before ever calling parentmodule on it. (A schema-defined
    # dateTime-restricting simpleType, e.g. ISO 20022's "ISODateTime", is a concrete struct - not a
    # Union - so it still reaches the walk below and correctly resolves as in-module.)
    T isa Union && return false
    m = parentmodule(T)
    while true
        m === module_ref && return true
        parent = parentmodule(m)
        parent === m && return false  # reached the top of the module hierarchy (Main/Base/Core)
        m = parent
    end
    return
end

"""
	get_field_type(::Type{T}, field_specification::Union{Symbol, Int}) where T <: Any

For a given type T return the type of the field determined by either the index or symbol field_specification. If the
type is a Union return the first type different from Nothing. This is intended to handle types of the pattern Union{Nothing, S}
which is intended to represent optional types.
"""
function get_base_field_type(@nospecialize(T::Type), field_index::Int)::DataType
    field_type = fieldtype(T, field_index)

    if typeof(field_type) == Union
        # extract type from optional
        field_type = first(filter(a -> a != Nothing, Base.uniontypes(field_type)))
    end

    return field_type
end

# Deliberate open-tail dict, not a candidate for compile-time (dispatch/const) ownership: T ranges
# over every struct type any user's schema might generate, at the user's own runtime - an
# unbounded, not-known-until-`include()`-time key set, not a closed type domain.
const field_type_cache = Dict{Tuple{DataType, Symbol}, DataType}()

get_type_from_symbol(type_symbol::Tuple{DataType, Symbol}) = get(field_type_cache, type_symbol, Nothing)

function get_base_field_type(@nospecialize(T::Type), field_symbol::Symbol)
    field_type = get_type_from_symbol((T, field_symbol))

    if field_type == Nothing
        if isprimitivetype(T)
            field_type = T
        elseif hasfield(T, field_symbol)
            field_type = fieldtype(T, field_symbol)
        elseif T <: AbstractVector
            # recurse rather than fieldtype(eltype(T), field_symbol) directly: the element type
            # can itself be a choice type (field_symbol living inside a NamedTuple, not a direct
            # struct field), same as the plain non-vector case just below.
            field_type = get_base_field_type(eltype(T), field_symbol)
        else
            # field could be inside NamedTuple
            named_tuples = filter(field_type -> field_type <: NamedTuple, fieldtypes(T))
            matching_named_tuple = first(filter(named_tuple -> hasfield(named_tuple, field_symbol), named_tuples))
            field_type = fieldtype(matching_named_tuple, field_symbol)
        end

        if typeof(field_type) == Union
            # extract type from optional
            field_type = first(filter(a -> a !== Nothing, Base.uniontypes(field_type)))
        end

        field_type_cache[(T, field_symbol)] = field_type
    end

    return field_type
end

# Same as field_type_cache above: tag names are open across all possible schemas, not a closed
# domain - a deliberate dict fallback, not a gap to close with dispatch.
const tag_symbol_cache = Dict{String, Symbol}()

"""
	tag_symbol(tag_name::AbstractString)::Symbol

Cached `Symbol(tag_name)` - a schema's tag-name universe is small and fixed, but this is called
once per XML node visited, so an uncached `Symbol()` call per node adds up on large documents.
"""
tag_symbol(tag_name::AbstractString)::Symbol = get!(() -> Symbol(tag_name), tag_symbol_cache, tag_name)

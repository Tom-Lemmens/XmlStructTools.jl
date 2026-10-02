
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
    m = parentmodule(T)
    while true
        m === module_ref && return true
        parent = parentmodule(m)
        parent === m && return false  # reached the top of the module hierarchy (Main/Base/Core)
        m = parent
    end
end

"""
	type_in_module(::Type{ZonedDateTime}, ::Module)

Handles special edge case that should always return false.
"""
type_in_module(::Type{T}, ::Module) where {T<:Dates.AbstractTime} = false

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

# Keyed by whatever struct types a user's schema generates, so a dict rather than dispatch.
# Nested rather than keyed by the pair `(T, field_symbol)`: a tuple holding a type is not plain
# data, so a single-level cache has to allocate its key on every lookup, hit or miss.
const field_type_cache = IdDict{Type,Dict{Symbol,DataType}}()

function get_base_field_type(@nospecialize(T::Type), field_symbol::Symbol)
    by_field = get(field_type_cache, T, nothing)
    if by_field !== nothing
        hit = get(by_field, field_symbol, nothing)
        hit === nothing || return hit
    end

    if isprimitivetype(T)
        field_type = T
    elseif hasfield(T, field_symbol)
        field_type = fieldtype(T, field_symbol)
    elseif T <: AbstractVector
        field_type = fieldtype(eltype(T), field_symbol)
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

    get!(() -> Dict{Symbol,DataType}(), field_type_cache, T)[field_symbol] = field_type

    return field_type
end

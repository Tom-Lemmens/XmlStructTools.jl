
XsdToStruct_SUBMODULE_SUFFIX = "Types"

@memoize function unames(m::Module; all::Bool = false, imported::Bool = false)
    return ccall(:jl_module_names, Array{Symbol,1}, (Any, Cint, Cint), m, all, imported)
end

"""
	(type_in_module(::Type{T}, module_ref::Module)::Bool) where T <: Any

Determine if given type T is defined in the module specified by module_symbol.
"""
function type_in_module(@nospecialize(T::Type), module_ref::Module)::Bool
    type_name = nameof(T)

    # check if type is defined in the module
    if type_name in unames(module_ref, all = true)
        return true
    end

    # check if the parent module of the type is defined in the module
    parent_module = parentmodule(T)
    parent_name = nameof(parent_module)
    # keep looking as long as submodule suffix matches suffix from XsdToStruct
    while endswith(string(parent_name), XsdToStruct_SUBMODULE_SUFFIX)
        if parent_name in unames(module_ref, all = true)
            return true
        end
        parent_module = parentmodule(parent_module)
        parent_name = nameof(parent_module)
    end
    return false
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

const field_type_cache = Dict{Tuple{DataType,Symbol},DataType}()

get_type_from_symbol(type_symbol::Tuple{DataType,Symbol}) = get(field_type_cache, type_symbol, Nothing)

function get_base_field_type(@nospecialize(T::Type), field_symbol::Symbol)
    field_type = get_type_from_symbol((T, field_symbol))

    if field_type == Nothing
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

        field_type_cache[(T, field_symbol)] = field_type
    end

    return field_type
end

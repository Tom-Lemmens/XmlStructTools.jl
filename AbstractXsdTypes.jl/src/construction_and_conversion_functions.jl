# Common constructors for most XSD types
for xsd_type in Base.uniontypes(AbstractXSDSimpleTypes)
    @eval begin
        (::Type{T})(value; __validated::Bool = true) where {T<:$xsd_type} = T(value, nothing, __validated)
        (::Type{T})(value, __validated::Bool) where {T<:$xsd_type} = T(value, nothing, __validated)
    end
end

# Common constructors for numeric types
for numeric_type in Base.uniontypes(AbstractXSDNumericTypes)
    @eval begin
        (::Type{T})(x::$numeric_type) where {T<:Number} = T(x.value)
    end
end

# conversions for numeric types
Base.convert(::Type{T}, x::AbstractXSDNumericTypes) where {T<:Number} = convert(T, x.value)
Base.convert(::Type{T}, x::T) where {T<:AbstractXSDNumericTypes} = x

# Attempt naive conversions for all XSD types
"""
    can_be_converted(::Type{T}, ::Type{S})::Bool where {T<:AbstractXSDComplex, S<:AbstractXSDComplex}

Naive check to see if type `S` can be converted to type `T`. This function will only look for compatible field names,
compatibility of field types is not checked.
"""
@memoize function can_be_converted(::Type{T}, ::Type{S})::Bool where {T<:AbstractXSDComplex,S<:AbstractXSDComplex}
    field_names_s = fieldnames(S)
    field_names_t = fieldnames(T)

    field_names_t_default = defaults(T) |> keys
    field_names_t_nodefault = setdiff(field_names_t, field_names_t_default)

    # check field names
    s_has_sufficient_fields = field_names_t_nodefault ⊆ field_names_s
    if !s_has_sufficient_fields
        @info "$S has insufficient fields for $T, missing: $(setdiff(field_names_t_nodefault, field_names_s))"
    end

    s_has_no_extra_fields = field_names_s ⊆ field_names_t
    if !s_has_no_extra_fields
        @info "$S has more fields then $T, extra fields: $(setdiff(field_names_s, field_names_t))"
    end

    conversion_possible = s_has_sufficient_fields && s_has_no_extra_fields

    @debug "Check $S has sufficient fields for $T: $s_has_sufficient_fields"
    @debug "Check $S has no extra fields for $T: $s_has_no_extra_fields"
    @debug "Conversion $S to $T possible: $conversion_possible"

    return conversion_possible
end

for xsd_type in Base.uniontypes(AbstractXSDAllTypes)
    @eval begin
        # naive conversion by just passing fields
        function Base.convert(::Type{T}, value::S) where {T<:$xsd_type,S<:$xsd_type}
            if can_be_converted(T, S)
                @debug "Convert called with $S to $T"
                kwargs = Dict(field_name => getfield(value, field_name) for field_name in fieldnames(S))
                return T(; kwargs...)
            else
                error("Type $S cannot be converted to type $T with the currently implemented convert functions.")
            end
        end

        # trivial conversion to prevent infinite looping of the function above.
        function Base.convert(::Type{T}, value::T) where {T<:$xsd_type}
            @debug "Trivial convert called with $T"
            return value
        end
    end
end

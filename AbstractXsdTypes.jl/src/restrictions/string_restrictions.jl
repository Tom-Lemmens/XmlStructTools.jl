@inline function string_length_restriction_check(::Type{T}, value::AbstractString)::Nothing where {T<:AbstractXSDString}
    max_length = get_max_string_length(T)
    min_length = get_min_string_length(T)

    if length(value) > max_length
        throw(
            XSDValueRestrictionViolationError(
                T,
                value,
                "Length of $(value) exceeds the maximum length ($(max_length)) for $(T).",
            ),
        )
    elseif length(value) < min_length
        throw(
            XSDValueRestrictionViolationError(
                T,
                value,
                "Length of $(value) is less than the minimum length ($(min_length)) for $(T).",
            ),
        )
    end

    return nothing
end

@inline get_max_string_length(::Type{<:AbstractXSDString})::Int = typemax(Int)
@inline get_min_string_length(::Type{<:AbstractXSDString})::Int = typemin(Int)

@inline function string_pattern_restriction_check(
    ::Type{T},
    value::AbstractString,
)::Nothing where {T<:AbstractXSDString}
    regex = get_string_pattern_regex(T)

    if !occursin(regex, value)
        throw(
            XSDValueRestrictionViolationError(
                T,
                value,
                "Given string $(value) does not match the pattern $(regex) for $(T).",
            ),
        )
    end

    return nothing
end

@inline get_string_pattern_regex(::Type{<:AbstractXSDString})::Regex = r""

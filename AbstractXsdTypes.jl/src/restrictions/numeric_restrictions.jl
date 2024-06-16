
# bounds for value
@inline function bound_restriction_check(::Type{T}, value::Real)::Nothing where {T<:AbstractXSDNumericTypes}
    max_value = get_max_value(T)
    min_value = get_min_value(T)

    if is_max_exclusive(T) ? max_value <= value : max_value < value
        throw(
            XSDValueRestrictionViolationError(
                T,
                value,
                "Value ($(value)) exceeds the maximum value ($(max_value)) for $(T).",
            ),
        )
    elseif is_min_exclusive(T) ? value <= min_value : value < min_value
        throw(
            XSDValueRestrictionViolationError(
                T,
                value,
                "Value $(value) is less than the minimum value ($(min_value)) for $(T).",
            ),
        )
    end

    return nothing
end

@inline is_max_exclusive(::Type{<:AbstractXSDNumericTypes})::Bool = true
@inline is_min_exclusive(::Type{<:AbstractXSDNumericTypes})::Bool = true

@inline get_max_value(::Type{<:AbstractXSDFloat})::Float64 = typemax(Float64)
@inline get_min_value(::Type{<:AbstractXSDFloat})::Float64 = typemin(Float64)

@inline get_max_value(::Type{<:AbstractXSDSigned})::Int64 = typemax(Int64)
@inline get_min_value(::Type{<:AbstractXSDSigned})::Int64 = typemin(Int64)

@inline get_max_value(::Type{<:AbstractXSDUnsigned})::UInt64 = typemax(UInt64)
@inline get_min_value(::Type{<:AbstractXSDUnsigned})::UInt64 = typemin(UInt64)

# total digits
@inline function total_digits_check(::Type{T}, value::Real)::Nothing where {T<:AbstractXSDFloat}
    string_value = split(string(value), "e") |> first
    before_period, after_period = split(string_value, ".")
    total_digits = length(before_period) + length(after_period)
    total_digits -= before_period == "0" ? 1 : 0  # workaround for 0 as last digit
    total_digits -= after_period == "0" ? 1 : 0  # workaround for 0 as leading digit

    max_total_digits = get_max_total_digits(T)

    if total_digits > max_total_digits
        throw(
            XSDValueRestrictionViolationError(
                T,
                value,
                "The total number of digits of ($(value)) exceed the maximum amount ($(max_total_digits)) for $(T).",
            ),
        )
    end

    return nothing
end

@inline function total_digits_check(
    ::Type{T},
    value::Real,
)::Nothing where {T<:Union{AbstractXSDSigned,AbstractXSDUnsigned}}
    total_digits = string(value) |> length

    max_total_digits = get_max_total_digits(T)

    if total_digits > max_total_digits
        throw(
            XSDValueRestrictionViolationError(
                T,
                value,
                "The number of total digits of ($(value)) exceed the maximum amount ($(max_total_digits)) for $(T).",
            ),
        )
    end

    return nothing
end

@inline get_max_total_digits(::Type{<:AbstractXSDNumericTypes})::Int = typemax(Int)

# fraction digits
@inline function fraction_digits_check(::Type{T}, value::S)::Nothing where {T<:AbstractXSDFloat,S<:Real}

    # format into string and parse back, if these are equal we are ok
    max_fraction_digits = get_max_fraction_digits(T)
    value_string = cfmt("%.$(max_fraction_digits)f", value)

    if parse(S, value_string) != value
        throw(
            XSDValueRestrictionViolationError(
                T,
                value,
                "The number of fraction digits of ($(value)) exceed the maximum amount ($(max_fraction_digits)) for $(T).",
            ),
        )
    end

    return nothing
end

@inline get_max_fraction_digits(::Type{<:AbstractXSDFloat})::Int = typemax(Int)

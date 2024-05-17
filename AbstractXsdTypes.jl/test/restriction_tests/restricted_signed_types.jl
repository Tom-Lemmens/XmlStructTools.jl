
const negative_signed_value = -10
const positive_signed_value = 10
const max_signed_digits = 5

for struct_name in (
    :MaxInclusiveRestrictedSigned,
    :MaxExclusiveRestrictedSigned,
    :MinInclusiveRestrictedSigned,
    :MinExclusiveRestrictedSigned,
    :MinMaxInclusiveRestrictedSigned,
    :MinMaxExclusiveRestrictedSigned,
    :DigitsRestrictedSigned,
)
    @eval begin
        Base.@kwdef @concrete struct $struct_name <: AbstractXsdTypes.AbstractXSDSigned
            value::Int64
            __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
            __validated::Bool = true
            function $struct_name(
                value::Int64,
                __xml_attributes::Union{Nothing,Dict{String,String}} = nothing,
                __validated::Bool = true,
            )
                if __validated
                    AbstractXsdTypes.check_restrictions($struct_name, value)
                end
                return new(value, __xml_attributes, __validated)
            end
        end
    end
end

# Inclusive max
@inline AbstractXsdTypes.get_max_value(::Type{MaxInclusiveRestrictedSigned})::Int = positive_signed_value

@inline AbstractXsdTypes.is_max_exclusive(::Type{MaxInclusiveRestrictedSigned})::Bool = false

@inline AbstractXsdTypes.get_restriction_checks(::Type{MaxInclusiveRestrictedSigned})::Tuple{Function} =
    (AbstractXsdTypes.bound_restriction_check,)

# Exclusive max
@inline AbstractXsdTypes.get_max_value(::Type{MaxExclusiveRestrictedSigned})::Int = positive_signed_value

@inline AbstractXsdTypes.is_max_exclusive(::Type{MaxExclusiveRestrictedSigned})::Bool = true

@inline AbstractXsdTypes.get_restriction_checks(::Type{MaxExclusiveRestrictedSigned})::Tuple{Function} =
    (AbstractXsdTypes.bound_restriction_check,)

# Inclusive min
@inline AbstractXsdTypes.get_min_value(::Type{MinInclusiveRestrictedSigned})::Int64 = negative_signed_value

@inline AbstractXsdTypes.is_min_exclusive(::Type{MinInclusiveRestrictedSigned})::Bool = false

@inline AbstractXsdTypes.get_restriction_checks(::Type{MinInclusiveRestrictedSigned})::Tuple{Function} =
    (AbstractXsdTypes.bound_restriction_check,)

# Exclusive min
@inline AbstractXsdTypes.get_min_value(::Type{MinExclusiveRestrictedSigned})::Int64 = negative_signed_value

@inline AbstractXsdTypes.is_min_exclusive(::Type{MinExclusiveRestrictedSigned})::Bool = true

@inline AbstractXsdTypes.get_restriction_checks(::Type{MinExclusiveRestrictedSigned})::Tuple{Function} =
    (AbstractXsdTypes.bound_restriction_check,)

# Inclusive min/max
@inline AbstractXsdTypes.get_min_value(::Type{MinMaxInclusiveRestrictedSigned})::Int64 = negative_signed_value
@inline AbstractXsdTypes.get_max_value(::Type{MinMaxInclusiveRestrictedSigned})::Int64 = positive_signed_value

@inline AbstractXsdTypes.is_min_exclusive(::Type{MinMaxInclusiveRestrictedSigned})::Bool = false
@inline AbstractXsdTypes.is_max_exclusive(::Type{MinMaxInclusiveRestrictedSigned})::Bool = false

@inline AbstractXsdTypes.get_restriction_checks(::Type{MinMaxInclusiveRestrictedSigned})::Tuple{Function} =
    (AbstractXsdTypes.bound_restriction_check,)

# Exclusive min/max
@inline AbstractXsdTypes.get_min_value(::Type{MinMaxExclusiveRestrictedSigned})::Int64 = negative_signed_value
@inline AbstractXsdTypes.get_max_value(::Type{MinMaxExclusiveRestrictedSigned})::Int64 = positive_signed_value

@inline AbstractXsdTypes.is_min_exclusive(::Type{MinMaxExclusiveRestrictedSigned})::Bool = true
@inline AbstractXsdTypes.is_max_exclusive(::Type{MinMaxExclusiveRestrictedSigned})::Bool = true

@inline AbstractXsdTypes.get_restriction_checks(::Type{MinMaxExclusiveRestrictedSigned})::Tuple{Function} =
    (AbstractXsdTypes.bound_restriction_check,)

# digits
@inline AbstractXsdTypes.get_max_total_digits(::Type{DigitsRestrictedSigned})::Int = max_signed_digits

@inline AbstractXsdTypes.get_restriction_checks(::Type{DigitsRestrictedSigned})::Tuple{Function} =
    (AbstractXsdTypes.total_digits_check,)

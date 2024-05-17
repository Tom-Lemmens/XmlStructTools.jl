
const min_unsigned_value = UInt64(5)
const max_unsigned_value = UInt64(10)
const max_unsigned_digits = 5

for struct_name in (
    :MaxInclusiveRestrictedUnsigned,
    :MaxExclusiveRestrictedUnsigned,
    :MinInclusiveRestrictedUnsigned,
    :MinExclusiveRestrictedUnsigned,
    :MinMaxInclusiveRestrictedUnsigned,
    :MinMaxExclusiveRestrictedUnsigned,
    :DigitsRestrictedUnsigned,
)
    @eval begin
        Base.@kwdef @concrete struct $struct_name <: AbstractXsdTypes.AbstractXSDUnsigned
            value::UInt64
            __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
            __validated::Bool = true
            function $struct_name(
                value::UInt64,
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
@inline AbstractXsdTypes.get_max_value(::Type{MaxInclusiveRestrictedUnsigned})::UInt64 = max_unsigned_value

@inline AbstractXsdTypes.is_max_exclusive(::Type{MaxInclusiveRestrictedUnsigned})::Bool = false

@inline AbstractXsdTypes.get_restriction_checks(::Type{MaxInclusiveRestrictedUnsigned})::Tuple{Function} =
    (AbstractXsdTypes.bound_restriction_check,)

# Exclusive max
@inline AbstractXsdTypes.get_max_value(::Type{MaxExclusiveRestrictedUnsigned})::UInt64 = max_unsigned_value

@inline AbstractXsdTypes.is_max_exclusive(::Type{MaxExclusiveRestrictedUnsigned})::Bool = true

@inline AbstractXsdTypes.get_restriction_checks(::Type{MaxExclusiveRestrictedUnsigned})::Tuple{Function} =
    (AbstractXsdTypes.bound_restriction_check,)

# Inclusive min
@inline AbstractXsdTypes.get_min_value(::Type{MinInclusiveRestrictedUnsigned})::UInt64 = min_unsigned_value

@inline AbstractXsdTypes.is_min_exclusive(::Type{MinInclusiveRestrictedUnsigned})::Bool = false

@inline AbstractXsdTypes.get_restriction_checks(::Type{MinInclusiveRestrictedUnsigned})::Tuple{Function} =
    (AbstractXsdTypes.bound_restriction_check,)

# Exclusive min
@inline AbstractXsdTypes.get_min_value(::Type{MinExclusiveRestrictedUnsigned})::UInt64 = min_unsigned_value

@inline AbstractXsdTypes.is_min_exclusive(::Type{MinExclusiveRestrictedUnsigned})::Bool = true

@inline AbstractXsdTypes.get_restriction_checks(::Type{MinExclusiveRestrictedUnsigned})::Tuple{Function} =
    (AbstractXsdTypes.bound_restriction_check,)

# Inclusive min/max
@inline AbstractXsdTypes.get_min_value(::Type{MinMaxInclusiveRestrictedUnsigned})::UInt64 = min_unsigned_value
@inline AbstractXsdTypes.get_max_value(::Type{MinMaxInclusiveRestrictedUnsigned})::UInt64 = max_unsigned_value

@inline AbstractXsdTypes.is_min_exclusive(::Type{MinMaxInclusiveRestrictedUnsigned})::Bool = false
@inline AbstractXsdTypes.is_max_exclusive(::Type{MinMaxInclusiveRestrictedUnsigned})::Bool = false

@inline AbstractXsdTypes.get_restriction_checks(::Type{MinMaxInclusiveRestrictedUnsigned})::Tuple{Function} =
    (AbstractXsdTypes.bound_restriction_check,)

# Exclusive min/max
@inline AbstractXsdTypes.get_min_value(::Type{MinMaxExclusiveRestrictedUnsigned})::UInt64 = min_unsigned_value
@inline AbstractXsdTypes.get_max_value(::Type{MinMaxExclusiveRestrictedUnsigned})::UInt64 = max_unsigned_value

@inline AbstractXsdTypes.is_min_exclusive(::Type{MinMaxExclusiveRestrictedUnsigned})::Bool = true
@inline AbstractXsdTypes.is_max_exclusive(::Type{MinMaxExclusiveRestrictedUnsigned})::Bool = true

@inline AbstractXsdTypes.get_restriction_checks(::Type{MinMaxExclusiveRestrictedUnsigned})::Tuple{Function} =
    (AbstractXsdTypes.bound_restriction_check,)

# digits
@inline AbstractXsdTypes.get_max_total_digits(::Type{DigitsRestrictedUnsigned})::Int = max_unsigned_digits

@inline AbstractXsdTypes.get_restriction_checks(::Type{DigitsRestrictedUnsigned})::Tuple{Function} =
    (AbstractXsdTypes.total_digits_check,)

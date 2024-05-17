
const negative_float_value = -10
const positive_float_value = 10
const max_float_digits = 5

for struct_name in (
    :MaxInclusiveRestrictedFloat,
    :MaxExclusiveRestrictedFloat,
    :MinInclusiveRestrictedFloat,
    :MinExclusiveRestrictedFloat,
    :MinMaxInclusiveRestrictedFloat,
    :MinMaxExclusiveRestrictedFloat,
    :TotalDigitsRestrictedFloat,
    :FractionDigitsRestrictedFloat,
    :ZeroFractionDigitsRestrictedFloat,
)
    @eval begin
        Base.@kwdef @concrete struct $struct_name <: AbstractXsdTypes.AbstractXSDFloat
            value::Float64
            __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
            __validated::Bool = true
            function $struct_name(
                value::Float64,
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
@inline AbstractXsdTypes.get_max_value(::Type{MaxInclusiveRestrictedFloat})::Int = positive_float_value

@inline AbstractXsdTypes.is_max_exclusive(::Type{MaxInclusiveRestrictedFloat})::Bool = false

@inline AbstractXsdTypes.get_restriction_checks(::Type{MaxInclusiveRestrictedFloat})::Tuple{Function} =
    (AbstractXsdTypes.bound_restriction_check,)

# Exclusive max
@inline AbstractXsdTypes.get_max_value(::Type{MaxExclusiveRestrictedFloat})::Int = positive_float_value

@inline AbstractXsdTypes.is_max_exclusive(::Type{MaxExclusiveRestrictedFloat})::Bool = true

@inline AbstractXsdTypes.get_restriction_checks(::Type{MaxExclusiveRestrictedFloat})::Tuple{Function} =
    (AbstractXsdTypes.bound_restriction_check,)

# Inclusive min
@inline AbstractXsdTypes.get_min_value(::Type{MinInclusiveRestrictedFloat})::Float64 = negative_float_value

@inline AbstractXsdTypes.is_min_exclusive(::Type{MinInclusiveRestrictedFloat})::Bool = false

@inline AbstractXsdTypes.get_restriction_checks(::Type{MinInclusiveRestrictedFloat})::Tuple{Function} =
    (AbstractXsdTypes.bound_restriction_check,)

# Exclusive min
@inline AbstractXsdTypes.get_min_value(::Type{MinExclusiveRestrictedFloat})::Float64 = negative_float_value

@inline AbstractXsdTypes.is_min_exclusive(::Type{MinExclusiveRestrictedFloat})::Bool = true

@inline AbstractXsdTypes.get_restriction_checks(::Type{MinExclusiveRestrictedFloat})::Tuple{Function} =
    (AbstractXsdTypes.bound_restriction_check,)

# Inclusive min/max
@inline AbstractXsdTypes.get_min_value(::Type{MinMaxInclusiveRestrictedFloat})::Float64 = negative_float_value
@inline AbstractXsdTypes.get_max_value(::Type{MinMaxInclusiveRestrictedFloat})::Float64 = positive_float_value

@inline AbstractXsdTypes.is_min_exclusive(::Type{MinMaxInclusiveRestrictedFloat})::Bool = false
@inline AbstractXsdTypes.is_max_exclusive(::Type{MinMaxInclusiveRestrictedFloat})::Bool = false

@inline AbstractXsdTypes.get_restriction_checks(::Type{MinMaxInclusiveRestrictedFloat})::Tuple{Function} =
    (AbstractXsdTypes.bound_restriction_check,)

# Exclusive min/max
@inline AbstractXsdTypes.get_min_value(::Type{MinMaxExclusiveRestrictedFloat})::Float64 = negative_float_value
@inline AbstractXsdTypes.get_max_value(::Type{MinMaxExclusiveRestrictedFloat})::Float64 = positive_float_value

@inline AbstractXsdTypes.is_min_exclusive(::Type{MinMaxExclusiveRestrictedFloat})::Bool = true
@inline AbstractXsdTypes.is_max_exclusive(::Type{MinMaxExclusiveRestrictedFloat})::Bool = true

@inline AbstractXsdTypes.get_restriction_checks(::Type{MinMaxExclusiveRestrictedFloat})::Tuple{Function} =
    (AbstractXsdTypes.bound_restriction_check,)

# total digits
@inline AbstractXsdTypes.get_max_total_digits(::Type{TotalDigitsRestrictedFloat})::Int = max_float_digits

@inline AbstractXsdTypes.get_restriction_checks(::Type{TotalDigitsRestrictedFloat})::Tuple{Function} =
    (AbstractXsdTypes.total_digits_check,)

# fraction digits
@inline AbstractXsdTypes.get_max_fraction_digits(::Type{FractionDigitsRestrictedFloat})::Int = max_float_digits

@inline AbstractXsdTypes.get_restriction_checks(::Type{FractionDigitsRestrictedFloat})::Tuple{Function} =
    (AbstractXsdTypes.fraction_digits_check,)

@inline AbstractXsdTypes.get_max_fraction_digits(::Type{ZeroFractionDigitsRestrictedFloat})::Int = 0

@inline AbstractXsdTypes.get_restriction_checks(::Type{ZeroFractionDigitsRestrictedFloat})::Tuple{Function} =
    (AbstractXsdTypes.fraction_digits_check,)

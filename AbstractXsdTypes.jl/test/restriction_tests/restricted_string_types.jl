
const min_string_length = 3
const max_string_length = 5 * min_string_length

for struct_name in (
    :MinLengthRestrictedString,
    :MaxLengthRestrictedString,
    :FixedLengthRestrictedString,
    :PatternRestrictedString,
    :PatternMinMaxLengthRestrictedString,
)
    @eval begin
        Base.@kwdef @concrete struct $struct_name <: AbstractXsdTypes.AbstractXSDString
            value::String
            __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
            __validated::Bool = true
            function $struct_name(
                value::String,
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

# Min length
@inline AbstractXsdTypes.get_min_string_length(::Type{MinLengthRestrictedString})::Int = min_string_length

@inline AbstractXsdTypes.get_restriction_checks(::Type{MinLengthRestrictedString})::Tuple{Function} =
    (AbstractXsdTypes.string_length_restriction_check,)

# Max length
@inline AbstractXsdTypes.get_max_string_length(::Type{MaxLengthRestrictedString})::Int = max_string_length

@inline AbstractXsdTypes.get_restriction_checks(::Type{MaxLengthRestrictedString})::Tuple{Function} =
    (AbstractXsdTypes.string_length_restriction_check,)

# Fixed length
@inline AbstractXsdTypes.get_min_string_length(::Type{FixedLengthRestrictedString})::Int = max_string_length
@inline AbstractXsdTypes.get_max_string_length(::Type{FixedLengthRestrictedString})::Int = max_string_length

@inline AbstractXsdTypes.get_restriction_checks(::Type{FixedLengthRestrictedString})::Tuple{Function} =
    (AbstractXsdTypes.string_length_restriction_check,)

# Pattern
@inline AbstractXsdTypes.get_string_pattern_regex(::Type{PatternRestrictedString})::Regex = r"^([0-9]{4})?$"

@inline AbstractXsdTypes.get_restriction_checks(::Type{PatternRestrictedString})::Tuple{Function} =
    (AbstractXsdTypes.string_pattern_restriction_check,)

# PatternMinMax
@inline AbstractXsdTypes.get_min_string_length(::Type{PatternMinMaxLengthRestrictedString})::Int = min_string_length
@inline AbstractXsdTypes.get_max_string_length(::Type{PatternMinMaxLengthRestrictedString})::Int = max_string_length
@inline AbstractXsdTypes.get_string_pattern_regex(::Type{PatternMinMaxLengthRestrictedString})::Regex = r"^([0-9]*)?$"

@inline AbstractXsdTypes.get_restriction_checks(::Type{PatternMinMaxLengthRestrictedString})::Tuple{Function,Function} =
    (AbstractXsdTypes.string_length_restriction_check, AbstractXsdTypes.string_pattern_restriction_check)

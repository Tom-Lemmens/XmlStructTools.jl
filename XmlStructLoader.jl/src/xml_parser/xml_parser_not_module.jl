# Vector{T} where T is in the module will get sent here
function _parse_xml_node_not_module(node::XmlStructLoaderNode, module_ref::Module, validate::Bool)
    T = node.type
    new_node = XmlStructLoaderNode(node.node, eltype(T), node.parent)

    return T([construct_xml_node_object(new_node, module_ref, validate)])
end

function parse_xml_node_not_module(
    @nospecialize(xml_node::UnifiedXMLElement),
    ::Type{T},
    module_ref::Module,
    validate::Bool,
    default_value::Union{Nothing,S},
)::Union{Nothing,T} where {T<:Number,S<:Number}
    content_string = content(xml_node)

    if content_string == ""
        return default_value
    else
        return Parsers.parse(T, content_string)
    end
end

function parse_xml_node_not_module(
    xml_node::UnifiedXMLElement,
    ::Type{T},
    module_ref::Module,
    validate::Bool,
    default_value,
)::T where {T<:AbstractString}
    content_string = content(xml_node) # for strings we need the raw content
    if !isnothing(default_value) && isempty(content_string)
        return T(default_value)
    else
        return T(content_string)
    end
end

function parse_xml_node_not_module(
    xml_node::UnifiedXMLElement,
    ::Type{<:Union{DateTime,ZonedDateTime}},
    module_ref::Module,
    validate::Bool,
    default_value::Union{Nothing,DateTime,ZonedDateTime},
)::Union{Nothing,DateTime,ZonedDateTime}
    content_string = get_node_content(xml_node)

    if isempty(content_string)
        return default_value
    else
        return parse_xml_date(content_string)
    end
end

# Regex inspired by section 3.2.7.3 Timezones of
# https://www.w3.org/TR/2004/REC-xmlschema-2-20041028/datatypes.html#dateTime
const timezone_regex = r"((\+|-)\d\d:\d\d)|Z"
const formatting_strings = map(s -> "yyyy-mm-ddTHH:MM:SS$(s)zzzzzz", ["", ".s", ".ss", ".sss"])
function parse_xml_date(date_string::AbstractString)::Union{DateTime,ZonedDateTime}
    timezone_match = match(timezone_regex, date_string)
    is_not_timezone_string = isnothing(timezone_match)

    preparsed_string, n_after_period = truncate_seconds(date_string)

    if is_not_timezone_string
        parsed_date = DateTime(preparsed_string, ISODateTimeFormat)
    else
        parsed_date = ZonedDateTime(preparsed_string, formatting_strings[n_after_period + 1])
    end

    return parsed_date
end

# Regex inspired by section 3.2.7.1 Lexical representation of
# https://www.w3.org/TR/2004/REC-xmlschema-2-20041028/datatypes.html#dateTime
const seconds_after_period_regex = r"^(-?\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.?)(\d*)(.*)$"
@inline function truncate_seconds(date_string::AbstractString)::Tuple{String,Int}
    # Check the amount of seconds after the decimal point and truncate to three digits.
    # Also throw a warning if this occurs.

    seconds_after_period_match = match(seconds_after_period_regex, date_string)
    n_after_period = isnothing(seconds_after_period_match) ? 0 : seconds_after_period_match.captures[2] |> length
    n_seconds_digits = n_after_period + 2

    if (n_seconds_digits > 5)
        @warn (
            "dateTime element with $n_seconds_digits > 5 second digits, " *
            "anything below milliseconds will be cutoff."
        ) maxlog = 1
        truncated_after_period = seconds_after_period_match.captures[2][1:3]
        truncated_string =
            (seconds_after_period_match.captures[1] * truncated_after_period * seconds_after_period_match.captures[3])
        n_after_period = 3
    else
        truncated_string = date_string
    end

    return truncated_string, n_after_period
end

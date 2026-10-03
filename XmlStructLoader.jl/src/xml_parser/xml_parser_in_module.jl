"""
	_child_fields(T, raw, module_ref, validate)

The constructor arguments for one complex element of type `T`: every child element under its
field name, with repeated elements of a `Vector`-typed field accumulated in document order.

Siblings are a loop and only nesting recurses, so the call depth is the document's nesting depth
and not its element count: a flat document with 120,000 sibling records descends one level.
"""
function _child_fields(
        @nospecialize(T::Type),
        @nospecialize(raw::UnifiedXMLElement),
        module_ref::Module,
        validate::Bool,
    )
    kw = Dict{Symbol, Any}()
    field_defaults = AbstractXsdTypes.defaults(T)
    child = XmlStructPugixml.first_child_element(raw)
    while child != C_NULL
        field_symbol = name_symbol(child)
        field_type = get_base_field_type(T, field_symbol)
        default_value = get(field_defaults, field_symbol, nothing)

        # A byte vector is the decoded content of ONE element, not a field that repeats:
        # `xs:base64Binary` maps to `Vector{UInt8}`, which would otherwise look like a repeated
        # element and have each byte parsed from the whole base64 text.
        if field_type <: AbstractVector && !(field_type <: AbstractVector{UInt8})
            element = construct_element(eltype(field_type), child, default_value, module_ref, validate)
            if haskey(kw, field_symbol)
                push!(kw[field_symbol], element)
            else
                elements = field_type()
                push!(elements, element)
                kw[field_symbol] = elements
            end
        else
            kw[field_symbol] = construct_element(field_type, child, default_value, module_ref, validate)
        end

        child = XmlStructPugixml.next_sibling_element(child)
    end
    return kw
end

"""
	construct_element(::Type{T}, raw, default_value, module_ref, validate)

The object for the XML element `raw` at field type `T`, children first.

`T` is a static parameter rather than a struct field, which keeps everything below this call
specialized: the one dynamic call per element happens here, where the field type is only known
at run time.
"""
function construct_element(
        ::Type{T},
        @nospecialize(raw::UnifiedXMLElement),
        default_value,
        module_ref::Module,
        validate::Bool,
    ) where {T}
    if haschildren(raw)
        kw = _child_fields(T, raw, module_ref, validate)
        return T(; __xml_attributes = getattributes_dict(raw), __validated = validate, kw...)
    end

    type_in_module(T, module_ref) ||
        return parse_xml_node_not_module(raw, T, module_ref, validate, default_value)

    if isempty(content(raw))
        isnothing(default_value) || return T(value = default_value)
        # An empty element still produces an object for these: a string type gets the empty
        # string, a complex type its own defaults. Anything else has no value to carry.
        T <: AbstractXsdTypes.AbstractXSDString && return T(value = "")
        T <: AbstractXsdTypes.AbstractXSDComplex && return T()
        return nothing
    end

    # Simple content: `T` wraps one public field whose type parses the element's text, so the
    # same element is read again under that type.
    value = construct_element(get_base_field_type(T, 1), raw, default_value, module_ref, validate)
    return T(value, getattributes_dict(raw), validate)
end

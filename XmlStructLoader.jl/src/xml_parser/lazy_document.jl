# Deferred loading: open a document without parsing it, then parse only the parts that are read.
#
# Two levels of deferral, and no more: the root's fields, and the elements of a repeated field.
# Anything reached below that point is built by the ordinary eager path, so a value handed back
# from here is an ordinary generated struct with no XML handle inside it - it stays valid after
# its document is closed.

"""
	PugixmlDocumentHandle

Owner of a parsed pugixml document, tying the document's lifetime to Julia's garbage collector.

`XmlStructPugixml.parse_file` returns a raw pointer to memory that must be freed exactly once.
A finalizer here does that when the handle becomes unreachable, so a document stays alive as long
as anything derived from it can still be read. [`close`](@ref) frees it immediately instead.

pugixml's memory is invisible to Julia's garbage collector, which sees a handle of a few bytes
rather than the hundreds of megabytes it owns. Collection of many documents is therefore not
prompt, and code that opens them in a loop should close each one rather than wait.
"""
mutable struct PugixmlDocumentHandle
    ptr::Ptr{Cvoid}

    function PugixmlDocumentHandle(ptr::Ptr{Cvoid})
        handle = new(ptr)
        finalizer(_free_document!, handle)
        return handle
    end
end

function _free_document!(handle::PugixmlDocumentHandle)::Nothing
    if handle.ptr != C_NULL
        XmlStructPugixml.free_doc(handle.ptr)
        handle.ptr = C_NULL
    end
    return nothing
end

"""
	close(handle::PugixmlDocumentHandle)

Free the document now. Idempotent, and safe after the finalizer has already run.
"""
Base.close(handle::PugixmlDocumentHandle)::Nothing = _free_document!(handle)

Base.isopen(handle::PugixmlDocumentHandle)::Bool = handle.ptr != C_NULL

# Every path that is about to read a node checks this first: the handle nulls its pointer when
# freed, so one comparison turns reading a closed document into an error instead of a read of
# freed memory.
function _check_open(handle::PugixmlDocumentHandle)::Nothing
    isopen(handle) ||
        throw(ArgumentError("this XML document is closed; its contents can no longer be read"))
    return nothing
end

"""
	LazyVector{T} <: AbstractVector{T}

The elements of a repeated XML element, each parsed on first access and kept thereafter.

`length`, `size` and iteration bounds come from the element pointers collected when the vector
was created, so counting elements costs nothing. `collect` parses all of them, which is the same
work an eager load would have done for this field.
"""
struct LazyVector{T} <: AbstractVector{T}
    handle::PugixmlDocumentHandle
    nodes::Vector{Ptr{Cvoid}}
    cache::Vector{Any}
    module_ref::Module
    validate::Bool
    default_value::Any
end

LazyVector{T}(
    handle::PugixmlDocumentHandle,
    nodes::Vector{Ptr{Cvoid}},
    module_ref::Module,
    validate::Bool,
    default_value,
) where {T} = LazyVector{T}(handle, nodes, Vector{Any}(undef, length(nodes)), module_ref, validate, default_value)

Base.size(elements::LazyVector) = (length(elements.nodes),)
Base.IndexStyle(::Type{<:LazyVector}) = IndexLinear()

function Base.getindex(elements::LazyVector{T}, i::Int) where {T}
    @boundscheck checkbounds(elements, i)
    # A slot is written once with a value every task would compute identically, so two tasks
    # racing here both do the work and agree on the result.
    isassigned(elements.cache, i) && return elements.cache[i]::T
    _check_open(elements.handle)
    element = construct_element(
        T,
        elements.nodes[i],
        elements.default_value,
        elements.module_ref,
        elements.validate,
    )
    elements.cache[i] = element
    return element::T
end

function Base.show(io::IO, elements::LazyVector{T}) where {T}
    read_count = count(i -> isassigned(elements.cache, i), eachindex(elements.cache))
    print(io, "LazyVector{", T, "}(", length(elements), " elements, ", read_count, " read)")
    return nothing
end

Base.show(io::IO, ::MIME"text/plain", elements::LazyVector) = show(io, elements)

"""
	LazyDocument{T}

An XML document opened but not parsed, presenting the fields of the root type `T`.

Reading a field parses that part of the document and keeps the result; reading a repeated field
gives a [`LazyVector`](@ref). `propertynames` lists the same fields the eager root object has.
Build the whole object with [`materialize`](@ref).

This is not itself a generated struct: `write_xml` and anything else expecting `T` needs
`materialize` first, which is also the point at which the full cost is paid.
"""
struct LazyDocument{T}
    _handle::PugixmlDocumentHandle
    _root::Ptr{Cvoid}
    _attrs::Dict{String, String}
    _module::Module
    _validate::Bool
    _names::Vector{Symbol}
    _cache::Vector{Any}
    _full::Base.RefValue{Any}
    _is_root::Bool
    _default::Any
end

const _LAZY_DOCUMENT_FIELDS = fieldnames(LazyDocument)

_deferred_type(::LazyDocument{T}) where {T} = T

"""
	lazyload(xml_path, module_ref; validate=true)
	lazyload(f, xml_path, module_ref; validate=true)

Open `xml_path` without parsing its contents and return a [`LazyDocument`](@ref) over the structs
in `module_ref`, or pass it to `f` and close it afterwards.

The returned document is parsed field by field as it is read, so opening a large file costs little
more than reading its bytes. The one-argument form keeps the document until it is garbage
collected or [`close`](@ref)d, which suits interactive work; the function form frees it on exit,
which is what a loop over many documents wants.

Validation applies to each part as it is parsed, exactly as in [`load`](@ref).

# Examples
```julia-repl
julia> doc = lazyload("payments.xml", PaymentsModule);

julia> length(doc.Transaction)          # no parsing
120000

julia> doc.Transaction[60000].Amount    # parses one record
```
"""
function lazyload(xml_path::AbstractString, module_ref::Module; validate::Bool = true)
    doc_ptr = XmlStructPugixml.parse_file(xml_path)
    doc_ptr == C_NULL && error("pugixml failed to parse $xml_path")
    handle = PugixmlDocumentHandle(doc_ptr)
    xml_root = XmlStructPugixml.root(doc_ptr)
    root_type = module_ref.__meta.root_type
    root_attributes = getattributes_dict(xml_root)
    root_attributes["__root_name"] = name(xml_root)
    field_names = _public_fieldnames(root_type)
    return LazyDocument{root_type}(
        handle,
        xml_root,
        root_attributes,
        module_ref,
        validate,
        field_names,
        Vector{Any}(undef, length(field_names)),
        Ref{Any}(nothing),
        true,
        nothing,
    )
end

lazyload(xml_path::AbstractString, module_path::AbstractString; validate::Bool = true) =
    lazyload(xml_path, import_module_from_xml(xml_path, module_path); validate = validate)

function lazyload(f::Function, xml_path::AbstractString, module_or_path; validate::Bool = true)
    doc = lazyload(xml_path, module_or_path; validate = validate)
    try
        return f(doc)
    finally
        close(doc)
    end
end

"""
	close(doc::LazyDocument)

Free the underlying document now. Fields already read stay usable, because they hold parsed
values rather than XML nodes; reading a field that has not been read yet raises an error.
"""
Base.close(doc::LazyDocument)::Nothing = close(getfield(doc, :_handle))

Base.isopen(doc::LazyDocument)::Bool = isopen(getfield(doc, :_handle))

_public_fieldnames(@nospecialize(T::Type)) =
    Symbol[f for f in fieldnames(T) if f !== :__xml_attributes && f !== :__validated]

Base.propertynames(doc::LazyDocument) = Tuple(getfield(doc, :_names))

function Base.getproperty(doc::LazyDocument, name::Symbol)
    name in _LAZY_DOCUMENT_FIELDS && return getfield(doc, name)
    name === :__xml_attributes && return getfield(doc, :_attrs)
    name === :__validated && return getfield(doc, :_validate)
    return _lazy_field(doc, name)
end

function _lazy_field(doc::LazyDocument{T}, name::Symbol) where {T}
    slot = findfirst(isequal(name), getfield(doc, :_names))
    isnothing(slot) && throw(ArgumentError("$T has no field $name"))
    cache = getfield(doc, :_cache)
    isassigned(cache, slot) && return cache[slot]
    value = _build_lazy_field(doc, name)
    cache[slot] = value
    return value
end

function _build_lazy_field(doc::LazyDocument{T}, name::Symbol) where {T}
    handle = getfield(doc, :_handle)
    _check_open(handle)
    module_ref = getfield(doc, :_module)
    validate = getfield(doc, :_validate)
    field_type = get_base_field_type(T, name)
    default_value = get(AbstractXsdTypes.defaults(T), name, nothing)
    nodes = _child_nodes_named(getfield(doc, :_root), name)

    # No element of that name: the field's value is whatever the eager object would hold, which
    # only the root type's own constructor knows, so build the root and read it from there.
    isempty(nodes) && return getproperty(materialize(doc), name)

    field_type <: AbstractVector &&
        return LazyVector{eltype(field_type)}(handle, nodes, module_ref, validate, default_value)

    node = first(nodes)
    # A generated complex type with element children becomes another deferred document; anything
    # else is a leaf whose value is parsed now.
    if type_in_module(field_type, module_ref) && haschildren(node)
        return _deferred_child(doc, field_type, node, default_value)
    end
    return construct_element(field_type, node, default_value, module_ref, validate)
end

function _deferred_child(doc::LazyDocument, @nospecialize(T::Type), node::Ptr{Cvoid}, default_value)
    field_names = _public_fieldnames(T)
    return LazyDocument{T}(
        getfield(doc, :_handle),
        node,
        getattributes_dict(node),
        getfield(doc, :_module),
        getfield(doc, :_validate),
        field_names,
        Vector{Any}(undef, length(field_names)),
        Ref{Any}(nothing),
        false,
        default_value,
    )
end

function _child_nodes_named(raw::Ptr{Cvoid}, name::Symbol)
    nodes = Ptr{Cvoid}[]
    child = XmlStructPugixml.first_child_element(raw)
    while child != C_NULL
        name_symbol(child) === name && push!(nodes, child)
        child = XmlStructPugixml.next_sibling_element(child)
    end
    return nodes
end

"""
	materialize(doc::LazyDocument)

Parse the whole document and return the ordinary root object, as [`load`](@ref) would have.

Kept after the first call, so passing the same document to `write_xml` twice parses it once.
"""
function materialize(doc::LazyDocument)
    full = getfield(doc, :_full)
    isnothing(full[]) || return full[]
    _check_open(getfield(doc, :_handle))
    object = if getfield(doc, :_is_root)
        construct_xml_root_object(
            getfield(doc, :_root),
            getfield(doc, :_module),
            copy(getfield(doc, :_attrs));
            validate = getfield(doc, :_validate),
        )
    else
        construct_element(
            _deferred_type(doc),
            getfield(doc, :_root),
            getfield(doc, :_default),
            getfield(doc, :_module),
            getfield(doc, :_validate),
        )
    end
    full[] = object
    return object
end

function Base.show(io::IO, doc::LazyDocument{T}) where {T}
    cache = getfield(doc, :_cache)
    read_count = count(i -> isassigned(cache, i), eachindex(cache))
    print(
        io,
        "LazyDocument{", nameof(T), "}(", length(getfield(doc, :_names)), " fields, ",
        read_count, " read, ", isopen(doc) ? "open" : "closed", ")",
    )
    return nothing
end

Base.show(io::IO, ::MIME"text/plain", doc::LazyDocument) = show(io, doc)

"""
	namespace_module_name(namespace::AbstractString)::Symbol

The module name for an XML namespace that no prefix is bound to, taken from the namespace's last
segment with anything that cannot appear in a Julia identifier replaced by `_`.

A schema that binds its target namespace to a prefix is named after that prefix instead; this
covers the schemas that bind it to the default `xmlns`, as the published ISO 20022 schemas do:
`urn:iso:std:iso:20022:tech:xsd:pacs.008.001.09` becomes `pacs_008_001_09`.

Both the generator and the loader call this, and they must agree: the generator writes a module
with this name and the loader looks one up by it.
"""
function namespace_module_name(namespace::AbstractString)::Symbol
    segments = filter(!isempty, split(namespace, (':', '/')))
    isempty(segments) &&
        throw(ArgumentError("cannot derive a module name from the namespace \"$namespace\""))
    cleaned = replace(last(segments), r"[^A-Za-z0-9_]" => "_")
    # A Julia identifier cannot start with a digit.
    occursin(r"^[0-9]", cleaned) && (cleaned = "_" * cleaned)
    return Symbol(cleaned)
end

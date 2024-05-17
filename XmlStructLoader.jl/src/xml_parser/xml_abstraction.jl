
# This is a poor man's abtraction for EzXML so that is easier to replace
UnifiedXMLElement = EzXML.Node

content(node::EzXML.Node) = EzXML.nodecontent(node) |> strip
attributes(node::EzXML.Node) = EzXML.eachattribute(node)
name(node::EzXML.Node) = EzXML.nodename(node)

hasattribute(node::EzXML.Node, attr::AbstractString) = findfirst(==(attr) ∘ name, eachattribute(node)) |> isnothing
hasattributes(node::EzXML.Node) = !isempty(eachattribute(node))
haschildren(node::EzXML.Node) = haselement(node)

function readxmlfile(f::Function, filename::AbstractString)
    @info "Loading with EzXML..."
    return f(EzXML.readxml(filename))
end

function readxmlfile(f::Function, io::IO)
    @info "Loading with EzXML..."
    return f(EzXML.readxml(io))
end

struct XmlStructLoaderNode{XML<:UnifiedXMLElement,T<:Union{DataType,Union}}
    node::XML
    type::T
    parent::Union{Nothing,XmlStructLoaderNode{XML}}
end

docroot(xml_doc::EzXML.Document) = EzXML.root(xml_doc)

AbstractTrees.parent(node::EzXML.Node) = parentnode(node)
AbstractTrees.parent(node::XmlStructLoaderNode) = isnothing(node.parent) ? node.node : node.parent

AbstractTrees.isroot(node::EzXML.Node) = (docroot ∘ document)(node) == node
AbstractTrees.isroot(node::XmlStructLoaderNode) = isroot(node.node)

function AbstractTrees.children(n::EzXML.Node)
    return eachelement(n)
end

function AbstractTrees.children(node::L)::Vector{L} where {L<:XmlStructLoaderNode}
    xml_children = children(node.node)

    r = map(xml_children) do child
        type = get_base_field_type(node.type, Symbol(name(child)))
        return XmlStructLoaderNode(child, type, node)
    end
    return r
end

# AbstractTrees Iterators
Base.IteratorEltype(::Type{<:TreeIterator{<:XmlStructLoaderNode}}) = Base.HasEltype()
Base.eltype(::Type{<:TreeIterator{T}}) where {T<:XmlStructLoaderNode} = T

AbstractTrees.ParentLinks(::Type{<:XmlStructLoaderNode}) = AbstractTrees.ImplicitParents()
AbstractTrees.SiblingLinks(::Type{<:XmlStructLoaderNode}) = AbstractTrees.StoredSiblings()

function AbstractTrees.nextsibling(node::XmlStructLoaderNode)
    if hasnextelement(node.node)
        sibling = nextelement(node.node)
        sibling_type = get_base_field_type(node.parent.type, Symbol(name(sibling)))
        return XmlStructLoaderNode(sibling, sibling_type, node.parent)
    else
        return nothing
    end
end

# AbstractTrees.NodeType(::Type{<:XmlStructLoaderNode}) = HasNodeType()
# AbstractTrees.nodetype(::Type{L}) where L <: XmlStructLoaderNode = L

function _get_default(@nospecialize(ParentType::Type), @nospecialize(child::UnifiedXMLElement))
    defaults = AbstractXsdTypes.defaults(ParentType)
    field = name(child) |> Symbol
    child_default = get(defaults, field, nothing)
    return child_default
end

get_default(node::XmlStructLoaderNode) = _get_default(node.parent.type, node.node)

function elementnames(element)
    excludes = (:__xml_attributes, :__validated)
    return filter(∉(excludes), fieldnames(element))
end

"""
	getattributes_dict(x::XMLElement)

Faster version of EzXML.attributes_dict()
"""
function getattributes_dict(x::EzXML.Node)
    local dct
    if hasattributes(x)
        dct = Dict(name(a) => nodecontent(a) for a in attributes(x))
    else
        dct = Dict{String,String}() # Return empty concrete Dict
    end
    return dct
end

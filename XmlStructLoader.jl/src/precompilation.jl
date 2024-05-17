function precompilation_statements()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    Base.VERSION >= v"1.9" &&
        Base.precompile(Tuple{typeof(Core.kwcall),NamedTuple{(:validate,),Tuple{Bool}},typeof(load),String,Module})  
    Base.precompile(Tuple{typeof(parse_xml_node_not_module),EzXML.Node,Type{ZonedDateTime},Module,Bool,Nothing})
    Base.precompile(Tuple{typeof(children),XmlStructLoaderNode{EzXML.Node}})
    Base.precompile(Tuple{typeof(type_in_module),Type,Module})
    Base.precompile(Tuple{typeof(get_base_field_type),Type,Symbol})
    Base.precompile(Tuple{typeof(_get_default),Type,EzXML.Node})
    Base.precompile(Tuple{typeof(parse_xml_node_not_module),EzXML.Node,Type{Int64},Module,Bool,Nothing})
    Base.precompile(Tuple{typeof(parse_xml_node_not_module),EzXML.Node,Type{Float64},Module,Bool,Nothing})
    Base.precompile(Tuple{typeof(parse_xml_node_not_module),EzXML.Node,Type{Bool},Module,Bool,Bool})
    return Base.precompile(Tuple{typeof(isroot),XmlStructLoaderNode{EzXML.Node}})
end

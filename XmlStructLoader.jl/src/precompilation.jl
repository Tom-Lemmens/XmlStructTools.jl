function precompilation_statements()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    Base.VERSION >= v"1.9" &&
        Base.precompile(Tuple{typeof(Core.kwcall),NamedTuple{(:validate,),Tuple{Bool}},typeof(load),String,Module})  
    Base.precompile(Tuple{typeof(parse_xml_node_not_module),Ptr{Cvoid},Type{ZonedDateTime},Module,Bool,Nothing})
    Base.precompile(Tuple{typeof(type_in_module),Type,Module})
    Base.precompile(Tuple{typeof(get_base_field_type),Type,Symbol})
    Base.precompile(Tuple{typeof(parse_xml_node_not_module),Ptr{Cvoid},Type{Int64},Module,Bool,Nothing})
    Base.precompile(Tuple{typeof(parse_xml_node_not_module),Ptr{Cvoid},Type{Float64},Module,Bool,Nothing})
    Base.precompile(Tuple{typeof(parse_xml_node_not_module),Ptr{Cvoid},Type{Bool},Module,Bool,Bool})
end

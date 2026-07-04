module TestRootElementInlineType_struct

import AbstractXsdTypes

Base.@kwdef struct document <: AbstractXsdTypes.AbstractXSDComplex
    Element_string::String
    Element_double::Float64
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export document

end

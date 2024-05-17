
Base.@kwdef @concrete struct XsdFloat1 <: AbstractXsdTypes.AbstractXSDFloat
    value::Float64
    __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
    __validated::Bool = true
end

Base.@kwdef @concrete struct XsdFloat2 <: AbstractXsdTypes.AbstractXSDFloat
    value::Float64
    __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
    __validated::Bool = true
end

Base.@kwdef @concrete struct XsdSigned1 <: AbstractXsdTypes.AbstractXSDSigned
    value::Int64
    __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
    __validated::Bool = true
end

Base.@kwdef @concrete struct XsdSigned2 <: AbstractXsdTypes.AbstractXSDSigned
    value::Int64
    __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
    __validated::Bool = true
end

Base.@kwdef @concrete struct XsdUnSigned1 <: AbstractXsdTypes.AbstractXSDUnsigned
    value::UInt64
    __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
    __validated::Bool = true
end

Base.@kwdef @concrete struct XsdUnSigned2 <: AbstractXsdTypes.AbstractXSDUnsigned
    value::UInt64
    __xml_attributes::Union{Nothing,Dict{String,String}} = nothing
    __validated::Bool = true
end

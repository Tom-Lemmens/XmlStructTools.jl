module xsd_struct

import AbstractXsdTypes

Base.@kwdef struct AddressType <: AbstractXsdTypes.AbstractXSDComplex
    street::String
    city::String
    state::String
    postalCode::Float64
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export AddressType

Base.@kwdef struct OwnerType <: AbstractXsdTypes.AbstractXSDComplex
    name::String
    address::AddressType
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export OwnerType

Base.@kwdef struct overallPropertiesType <: AbstractXsdTypes.AbstractXSDComplex
    totalArea::Float64
    livableArea::Float64
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export overallPropertiesType

Base.@kwdef struct roomType <: AbstractXsdTypes.AbstractXSDComplex
    name::String
    area::Float64
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export roomType

Base.@kwdef struct HouseDescriptionType <: AbstractXsdTypes.AbstractXSDComplex
    overallProperties::overallPropertiesType
    room::Vector{roomType}
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export HouseDescriptionType

Base.@kwdef struct HouseDescriptionDocumentType <: AbstractXsdTypes.AbstractXSDComplex
    address::AddressType
    owner::OwnerType
    houseDescription::HouseDescriptionType
    __xml_attributes::Union{Nothing, Dict{String, String}} = nothing
    __validated::Bool = true
end

export HouseDescriptionDocumentType

end

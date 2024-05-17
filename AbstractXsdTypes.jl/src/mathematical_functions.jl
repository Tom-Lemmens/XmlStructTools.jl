
Base.:-(x::AbstractXSDNumericTypes) = -x.value

Base.:+(x::AbstractXSDNumericTypes, y::AbstractXSDNumericTypes) = x.value + y.value

Base.:-(x::AbstractXSDNumericTypes, y::AbstractXSDNumericTypes) = x - y

Base.:*(x::AbstractXSDNumericTypes, y::AbstractXSDNumericTypes) = x * y

Base.:/(x::AbstractXSDNumericTypes, y::AbstractXSDNumericTypes) = x / y

Base.:(==)(x::AbstractXSDNumericTypes, y::AbstractXSDNumericTypes) = x.value == y.value
Base.isequal(x::AbstractXSDNumericTypes, y::AbstractXSDNumericTypes) = Base.isequal(x.value, y.value)

Base.isless(x::AbstractXSDNumericTypes, y::AbstractXSDNumericTypes) = Base.isless(x.value, y.value)
Base.:<(x::AbstractXSDNumericTypes, y::AbstractXSDNumericTypes) = x.value < y.value

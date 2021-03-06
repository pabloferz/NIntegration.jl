mutable struct Box{T}
    x::T

    Box{T}() where {T} = new()
    Box{T}(x) where {T} = new(x)
end
Box(x::T) where {T} = Box{T}(x)

struct Region{N,T<:AbstractFloat,R}
    x::MVector{N,T} # center
    h::MVector{N,T} # half-width
    I::Box{R}
    E::Box{R}
    axis::Box{Int8}
end
Region(::Type{R}, x::NTuple{N,T}, h::NTuple{N,T}) where {R,N,T} =
    Region{N,T,R}(MVector(x), MVector(h), Box{R}(), Box{R}(), Box(Int8(0)))
Region(x::NTuple{N,T}, h::NTuple{N,T}) where {N,T} =
    Region{N,T,Float64}(MVector(x), MVector(h), Box(0.0), Box(0.0), Box(Int8(0)))

struct Regions{R<:Region}
    v::Vector{R}
end

struct WPoints{N,T,R}
    w::Vector{R}
    p::Vector{SVector{N,T}}
end

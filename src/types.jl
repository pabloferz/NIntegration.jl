type Box{T}
    x::T

    Box() = new()
    Box(x) = new(x)
end
(::Type{Box}){T}(x::T) = Box{T}(x)

immutable Region{N,T<:AbstractFloat,R}
    x::MVector{N,T} # center
    h::MVector{N,T} # half-width
    I::Box{R}
    E::Box{R}
    axis::Box{Int8}
end
(::Type{Region}){R,N,T}(::Type{R}, x::NTuple{N,T}, h::NTuple{N,T}) =
    Region{N,T,R}(MVector(x), MVector(h), Box{R}(), Box{R}(), Box(Int8(0)))
(::Type{Region}){N,T}(x::NTuple{N,T}, h::NTuple{N,T}) =
    Region{N,T,Float64}(MVector(x), MVector(h),
                        Box(0.0), Box(0.0), Box(Int8(0)))

Base.isless{N}(r₁::Region{N}, r₂::Region{N}) = isless(r₁.E.x, r₂.E.x)
Base.isequal{N}(r₁::Region{N}, r₂::Region{N}) = isequal(r₁.E.x, r₂.E.x)

Base.show(io::IO, r::Region) = print(io, '(', r.x, ", ", r.h, ')')

immutable Regions{R<:Region}
    v::Vector{R}
end

Base.size(r::Regions) = size(r.v)
Base.getindex(r::Regions, i::Int) = r.v[i]
Base.setindex!(r::Regions, v, i::Int) = (r.v[i] = v)

Base.show(io::IO, m::MIME"text/plain", r::Regions) = show(io, m, r.v)
Base.show(io::IO, r::Regions) =
    (n = length(r.v); print(io, n, " subregion", n == 1 ? "" : "s"))

immutable WPoints{N,T,R}
    w::Vector{R}
    p::Vector{SVector{N,T}}
end

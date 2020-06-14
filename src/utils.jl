#############################
#   Programming utilities   #
#############################

for N = 1:4
    # Equivalent to `integral_type(f, x) = typeof(p₀[1] * f(x...)` but inferrable
    @eval function integral_type(f, x::NTuple{$N,T}) where {T}
        Base.Cartesian.@nexprs $N d->(x_d = x[d])
        return typeof(p₀[1] * Base.Cartesian.@ncall($N, f, x))
    end

    # Equivalent to `evaluate(f, wp) = wp.w * f(wp.p...)`, but faster
    @eval function evaluate(f::F, v::SVector{$N,T}) where {F, T}
        Base.Cartesian.@nexprs $N d->(x_d = v[d])
        return Base.Cartesian.@ncall($N, f, x)
    end
end

idem(x, t) = (x, t)

### Getters and setters
weights(wp::WPoints) = wp.w
points(wp::WPoints) = wp.p

###############################
#   Array related utilities   #
###############################

Base.length(r::Regions) = length(r.v)
Base.getindex(r::Regions, i::Int) = r.v[i]

function Base.push!(wp::WPoints{N,T,R}, t::Tuple{R,SVector{N,T}}) where {N,T,R}
    push!(wp.w, t[1])
    push!(wp.p, t[2])
end

######################
#   Math utilities   #
######################

chop(x::T) where {T} = ifelse(x < eps(T), zero(T), x)

Base.isless(r₁::Region{N}, r₂::Region{N}) where {N} = isless(r₁.E.x, r₂.E.x)
Base.isequal(r₁::Region{N}, r₂::Region{N}) where {N} = isequal(r₁.E.x, r₂.E.x)

####################
#   IO utilities   #
####################

Base.show(io::IO, r::Region) = print(io, '(', r.x, ", ", r.h, ')')

Base.show(io::IO, m::MIME"text/plain", r::Regions) = show(io, m, r.v)
Base.show(io::IO, r::Regions) =
    (n = length(r.v); print(io, n, " subregion", n == 1 ? "" : "s"))

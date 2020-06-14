#############################
#   Programming utilities   #
#############################

for N = 1:4
    # Equivalent to `integral_type(f, x) = typeof(p₀[1] * f(x...)` but inferrable
    @eval function integral_type{T}(f, x::NTuple{$N,T})
        Base.Cartesian.@nexprs $N d->(x_d = x[d])
        return typeof(p₀[1] * Base.Cartesian.@ncall($N, f, x))
    end

    # Equivalent to `evaluate(f, wp) = wp.w * f(wp.p...)`, but faster
    @eval function evaluate{F,T}(f::F, v::SVector{$N,T})
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

function Base.push!{N,T,R}(wp::WPoints{N,T,R}, t::Tuple{R,SVector{N,T}})
    push!(wp.w, t[1])
    push!(wp.p, t[2])
end

######################
#   Math utilities   #
######################

chop{T}(x::T) = ifelse(x < eps(T), zero(T), x)

Base.isless{N}(r₁::Region{N}, r₂::Region{N}) = isless(r₁.E.x, r₂.E.x)
Base.isequal{N}(r₁::Region{N}, r₂::Region{N}) = isequal(r₁.E.x, r₂.E.x)

####################
#   IO utilities   #
####################

Base.show(io::IO, r::Region) = print(io, '(', r.x, ", ", r.h, ')')

Base.show(io::IO, m::MIME"text/plain", r::Regions) = show(io, m, r.v)
Base.show(io::IO, r::Regions) =
    (n = length(r.v); print(io, n, " subregion", n == 1 ? "" : "s"))

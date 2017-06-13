for N = 1:4
    # Equivalent to `integral_type(f, x) = typeof(p₀[1] * f(x...)` but inferrable
    @eval function integral_type(f, x::NTuple{$N})
        Base.Cartesian.@nexprs $N d->(x_d = x[d])
        return typeof(p₀[1] * Base.Cartesian.@ncall($N, f, x))
    end

    # Equivalent to `eval(f, wp) = wp.w * f(wp.p...)`, but faster
    @eval function eval{F,T}(f::F, v::SVector{$N,T})
        Base.Cartesian.@nexprs $N d->(x_d = v[d])
        return Base.Cartesian.@ncall($N, f, x)
    end
end

function Base.push!{N,T}(wp::WPoints{N,T}, t::Tuple{T,SVector{N,T}})
    push!(wp.w, t[1])
    push!(wp.p, t[2])
end

weights(wp::WPoints) = wp.w
points(wp::WPoints) = wp.p

idem(x, t) = (x, t)

chop{T}(x::T) = ifelse(x < eps(T), zero(T), x)

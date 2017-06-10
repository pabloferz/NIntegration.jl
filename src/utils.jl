# Equivalent to `integral_type(f, x) = typeof(p₀[1] * f(x...)` but inferrable
for N = 1:4
    @eval function integral_type(f, x::NTuple{$N})
        Base.Cartesian.@nexprs $N d->(x_d = x[d])
        return typeof(p₀[1] * Base.Cartesian.@ncall($N, f, x))
    end
end

chop{T}(x::T) = ifelse(x < eps(T), zero(T), x)

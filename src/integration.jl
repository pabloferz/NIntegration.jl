"""    nintegrate(f, xmin::NTuple{N,Any}, xmax::NTuple{N,Any};
               reltol = 1e-6, abstol = 1e-12,
               maxevals = 1000000)

Approximate numerical integration routine based on an adaptive algorithm
[^BEG1991].

- `f` is the integrand.
- `xmin` and `xmax` are tuples specifiying the boundaries of the integration
  domain.
- `reltol`, `abstol` and `maxevals` are optional keyword arguments that
  determine the termination criteria.

Returns a tuple of the approximated integral, error estimate, number of
functions evaluations and an object of type `Regions` (a set of subregions in
which the integration domain was subdivided).

[^BEG1991]: J. Berntsen, T. O. Espelid, A. Genz, "An Adaptive Algorithm for the
Approximate Calculation of Multiple Integrals," ACM Trans. Math. Soft., 17 (4),
437-451 (1991).
"""
function nintegrate{F,N}(f::F, xmin::NTuple{N,Any}, xmax::NTuple{N,Any};
                         reltol::Float64 = 1e-6, abstol::Float64 = eps(),
                         maxevals::Int = 1000000)
    # find the center and half-widths of the whole integration domain
    tx = map((a, b) -> (a + b) / 2, xmin, xmax)
    th = map((a, b) -> (b - a) / 2, xmin, xmax)
    T = Base.promote_typeof(tx..., th...)
    x, h = map(T, tx), map(T, th)
    r = Region(integral_type(f, x), x, h)

    # apply the integration rule to the whole domain
    # and initiate the regions heap
    _p = zeros(MMatrix{2,N,T})
    I, E = apply_rule!(f, r, _p)
    regions = binary_maxheap(typeof(r))
    push!(regions, r)
    evals = L = L₁₁

    # adaptively subdivide regions until the termination criteria is met
    while evals < maxevals && E > abs(I) * reltol && E > abstol
        r = pop!(regions)
        r₁, r₂ = divide(r)
        I₁, E₁ = apply_rule!(f, r₁, _p)
        I₂, E₂ = apply_rule!(f, r₂, _p)
        ΔI, ΔE = error_estimates!(r₁, r₂, r, I₁, I₂, E₁, E₂)

        push!(regions, r₁)
        push!(regions, r₂)

        evals += 2L
        I += ΔI
        E += ΔE
    end

    return I, E, evals, Regions(regions.valtree)
end

"""    nintegrate(f, regions::Regions)

Approximate numerical integration routine that takes the integrand `f` and a
`Regions` object which is a subdivision of the integration domain.
"""
nintegrate{F}(f::F, regions::Regions) = nintegrate(f, regions.v)
function nintegrate{F,N,R,T}(f::F, regions::Vector{Region{N,T,R}})
    _p = zeros(MMatrix{2,N,T})
    I  = zero(R)
    for r in regions
        I += apply_rule(f, r, _p)
    end
    return I
end

"""    nintegrate{T<:WPoint}(f, W::Vector{T})

Approximate numerical integration routine that takes the integrand `f` and a
`WPoints` object (set of  weights and nodes on integration domain). A `WPoints`
can be obtained from a `Regions` object `R` by calling `weightedpoints(R)`.
"""
function nintegrate{F,N,T}(f::F, wp::WPoints{N,T})
    w = weights(wp)
    p = points(wp)

    isempty(w) && throw(ArgumentError("W must contain at least one element"))

    I = w[1] * eval(f, p[1])
    @inbounds @simd for i = 2:length(w)
        I += w[i] * eval(f, p[i])
    end

    return I
end

"""    weightedpoints(regions::Regions)

Build a `WPoints` (`W`) from a `Regions` object `regions`.  The resulting
object can be used to approximate de integral of a function `f` by calling
`nintegrate(f, W)`
"""
weightedpoints(regions::Regions) = weightedpoints(idem, regions.v)

"""    weightedpoints(f, regions::Regions)

It works the same as `weightedpoints(::Regions)`, but allows a transformation
`f` that takes a weight and a tuple `x` of point coordinates f(w, p) and
returns a `WPoints`.
"""
weightedpoints{F}(f::F, regions::Regions) = weightedpoints(f, regions.v)
function weightedpoints{F,N,R,T}(f::F, regions::Vector{Region{N,T,R}})
    _p = zeros(MMatrix{2,N,T})
    w = Vector{R}()
    p = Vector{SVector{N,T}}()
    wp = WPoints(w, p)
    for r in regions
        weightedpoints!(f, wp, r, _p)
    end
    return wp
end

function divide(r::Region)
    i = r.axis.x
    r₁ = deepcopy(r)
    r₂ = deepcopy(r)
    r₁.x[i] -= r.h[i] / 2
    r₂.x[i] += r.h[i] / 2
    r₁.h[i] = r₂.h[i] = r.h[i] / 2
    return r₁, r₂
end

function apply_rule!{F}(f::F, r::Region, P)
    I, N₁, N₂, N₃, N₄, fu, fuα₁, fuα₂ = _apply_rule(f, r, P)
    r.axis.x = choose_axis(r.h, fu, fuα₁, fuα₂)
    E = compute_error(N₁, N₂, N₃, N₄)
    V = prod(r.h)
    I = r.I.x = V * I
    E = r.E.x = 8V * E
    return I, E
end

function choose_axis(h, fu, fuα₁, fuα₂)
    r = (α₁ / α₂)^2
    fc = 2fu * (1 - r)
    Df₁ = chop(abs(fuα₁[1] - r * fuα₂[1] - fc))
    Df₂ = chop(abs(fuα₁[2] - r * fuα₂[2] - fc))
    Df₃ = chop(abs(fuα₁[3] - r * fuα₂[3] - fc))

    if Df₁ == Df₂ == Df₃
        return indmax(h)
    else
        return indmax((Df₁, Df₂, Df₃))
    end
end

function compute_error(N₁, N₂, N₃, N₄)
    N₁⃰ = N₂⃰ = N₃⃰ = zero(N₁)

    @inbounds for i = 1:length(s₁)
        N₁⃰ = max(N₁⃰, abs(μ₁[i] * N₁ + N₂) * s₁[i])
        N₂⃰ = max(N₂⃰, abs(μ₂[i] * N₂ + N₃) * s₂[i])
        N₃⃰ = max(N₃⃰, abs(μ₃[i] * N₃ + N₄) * s₃[i])
    end
    @inbounds for i = length(s₁)+1:length(s₃)
        N₂⃰ = max(N₂⃰, abs(μ₂[i] * N₂ + N₃) * s₂[i])
        N₃⃰ = max(N₃⃰, abs(μ₃[i] * N₃ + N₄) * s₃[i])
    end
    @inbounds for i = length(s₃)+1:length(s₂)
        N₂⃰ = max(N₂⃰, abs(μ₂[i] * N₂ + N₃) * s₂[i])
    end

    if c[1] * N₁⃰ ≤ N₂⃰ && c[2] * N₂⃰ ≤ N₃⃰
        return c[3] * N₁⃰
    else
        return c[4] * max(N₁⃰, N₂⃰, N₃⃰)
    end
end

function error_estimates!(r₁, r₂, r, I₁, I₂, E₁, E₂)
    ΔI = I₁ + I₂ - r.I.x

    E₂⃰ = abs(ΔI)
    if (E₁⃰ = E₁ + E₂) > 0
        E₁ += c[5] * E₁ * E₂⃰ / E₁⃰
        E₂ += c[5] * E₂ * E₂⃰ / E₁⃰
    end
    E₁ += c[6] * E₂⃰
    E₂ += c[6] * E₂⃰

    ΔE = E₁ + E₂ - r.E.x
    r₁.E.x = E₁
    r₂.E.x = E₂

    return ΔI, ΔE
end

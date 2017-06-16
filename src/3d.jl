function _apply_rule{F,T,R}(f::F, r::Region{3,T,R}, p::MMatrix{2,3,T})
    x₁, x₂, x₃ = r.x
    h₁, h₂, h₃ = r.h

    fu = f(x₁, x₂, x₃)
    I = p₀[1] * fu
    N₁ = p₀[2] * fu
    N₂ = p₀[3] * fu
    N₃ = p₀[4] * fu
    N₄ = p₀[5] * fu

    # points generated by (αᵢ, 0, 0, 0, ...)
    u = α₁
    w, w₁, w₂, w₃, w₄ = wa[1]

    uh₁, uh₂, uh₃ = u * h₁, u * h₂, u * h₃
    p[1], p[3], p[5] = x₁ + uh₁, x₂ + uh₂, x₃ + uh₃
    p[2], p[4], p[6] = x₁ - uh₁, x₂ - uh₂, x₃ - uh₃

    fuα₁ = ( f(p[1], x₂, x₃) + f(p[2], x₂, x₃) ,
             f(x₁, p[3], x₃) + f(x₁, p[4], x₃) ,
             f(x₁, x₂, p[5]) + f(x₁, x₂, p[6]) )

    s = fuα₁[1] + fuα₁[2] + fuα₁[3]

    I += w * s
    N₁ += w₁ * s
    N₂ += w₂ * s
    N₃ += w₃ * s
    N₄ += w₄ * s

    u = α₂
    w, w₁, w₂, w₃, w₄ = wa[2]

    uh₁, uh₂, uh₃ = u * h₁, u * h₂, u * h₃
    p[1], p[3], p[5] = x₁ + uh₁, x₂ + uh₂, x₃ + uh₃
    p[2], p[4], p[6] = x₁ - uh₁, x₂ - uh₂, x₃ - uh₃

    fuα₂ = ( f(p[1], x₂, x₃) + f(p[2], x₂, x₃) ,
             f(x₁, p[3], x₃) + f(x₁, p[4], x₃) ,
             f(x₁, x₂, p[5]) + f(x₁, x₂, p[6]) )

    s = fuα₂[1] + fuα₂[2] + fuα₂[3]

    I += w * s
    N₁ += w₁ * s
    N₂ += w₂ * s
    N₃ += w₃ * s
    N₄ += w₄ * s

    @inbounds for i = 3:length(α)
        u = α[i]
        w, w₁, w₂, w₃, w₄ = wa[i]

        uh₁, uh₂, uh₃ = u * h₁, u * h₂, u * h₃
        p[1], p[3], p[5] = x₁ + uh₁, x₂ + uh₂, x₃ + uh₃
        p[2], p[4], p[6] = x₁ - uh₁, x₂ - uh₂, x₃ - uh₃

        s = f(p[1], x₂, x₃) + f(x₁, p[3], x₃) + f(x₁, x₂, p[5]) +
            f(p[2], x₂, x₃) + f(x₁, p[4], x₃) + f(x₁, x₂, p[6])

        I += w * s
        N₁ += w₁ * s
        N₂ += w₂ * s
        N₃ += w₃ * s
        N₄ += w₄ * s
    end

    # points generated by (βᵢ, βᵢ, 0, 0, ...)
    @inbounds for i = 1:length(β)
        u = β[i]
        w, w₁, w₂, w₃, w₄ = wb[i]

        uh₁, uh₂, uh₃ = u * h₁, u * h₂, u * h₃
        p[1], p[3], p[5] = x₁ + uh₁, x₂ + uh₂, x₃ + uh₃
        p[2], p[4], p[6] = x₁ - uh₁, x₂ - uh₂, x₃ - uh₃

        s = f(p[1], p[3], x₃) + f(p[1], x₂, p[5]) + f(x₁, p[3], p[5]) +
            f(p[1], p[4], x₃) + f(p[1], x₂, p[6]) + f(x₁, p[3], p[6]) +
            f(p[2], p[3], x₃) + f(p[2], x₂, p[5]) + f(x₁, p[4], p[5]) +
            f(p[2], p[4], x₃) + f(p[2], x₂, p[6]) + f(x₁, p[4], p[6])

        I += w * s
        N₁ += w₁ * s
        N₂ += w₂ * s
        N₃ += w₃ * s
        N₄ += w₄ * s
    end

    # points generated by (ɛᵢ, ɛᵢ, ɛᵢ, 0, ...)
    @inbounds for i = 1:length(ɛ)
        u = ɛ[i]
        w, w₁, w₂, w₃, w₄ = wd[i]

        uh₁, uh₂, uh₃ = u * h₁, u * h₂, u * h₃
        p[1], p[3], p[5] = x₁ + uh₁, x₂ + uh₂, x₃ + uh₃
        p[2], p[4], p[6] = x₁ - uh₁, x₂ - uh₂, x₃ - uh₃

        s = zero(R)
        for l = 1:2, m = 1:2, n = 1:2
            s += f(p[l, 1], p[m, 2], p[n, 3])
        end

        I += w * s
        N₁ += w₁ * s
        N₂ += w₂ * s
        N₃ += w₃ * s
        N₄ += w₄ * s
    end

    # points generated by (ζᵢ, ζᵢ, ηᵢ, 0, ...)
    @inbounds for i = 1:length(ζ)
        u, v = ζ[i], η[i]
        w, w₁, w₂, w₃, w₄ = we[i]

        uh₁, uh₂, uh₃ = u * h₁, u * h₂, v * h₃
        p[1], p[3], p[5] = x₁ + uh₁, x₂ + uh₂, x₃ + uh₃
        p[2], p[4], p[6] = x₁ - uh₁, x₂ - uh₂, x₃ - uh₃

        s = zero(R)
        for l = 1:2, m = 1:2, n = 1:2
            s += f(p[l, 1], p[m, 2], p[n, 3])
        end

        uh₂, uh₃ = v * h₂, u * h₃
        p[3], p[5] = x₂ + uh₂, x₃ + uh₃
        p[4], p[6] = x₂ - uh₂, x₃ - uh₃

        for l = 1:2, m = 1:2, n = 1:2
            s += f(p[l, 1], p[m, 2], p[n, 3])
        end

        uh₁, uh₂ = v * h₁, u * h₂
        p[1], p[3] = x₁ + uh₁, x₂ + uh₂
        p[2], p[4] = x₁ - uh₁, x₂ - uh₂

        for l = 1:2, m = 1:2, n = 1:2
            s += f(p[l, 1], p[m, 2], p[n, 3])
        end

        I += w * s
        N₁ += w₁ * s
        N₂ += w₂ * s
        N₃ += w₃ * s
        N₄ += w₄ * s
    end

    return I, N₁, N₂, N₃, N₄, fu, fuα₁, fuα₂
end

function apply_rule{F,R,T}(f::F, r::Region{3,T,R}, p::MMatrix{2,3,T})
    x₁, x₂, x₃ = r.x
    h₁, h₂, h₃ = r.h

    fu = f(x₁, x₂, x₃)
    I = p₀[1] * fu

    # points generated by (αᵢ, 0, 0, 0, ...)
    @inbounds for i = 1:length(α)
        u = α[i]

        uh₁, uh₂, uh₃ = u * h₁, u * h₂, u * h₃
        p[1], p[3], p[5] = x₁ + uh₁, x₂ + uh₂, x₃ + uh₃
        p[2], p[4], p[6] = x₁ - uh₁, x₂ - uh₂, x₃ - uh₃

        s = f(p[1], x₂, x₃) + f(x₁, p[3], x₃) + f(x₁, x₂, p[5]) +
            f(p[2], x₂, x₃) + f(x₁, p[4], x₃) + f(x₁, x₂, p[6])

        I += wa[i][1] * s
    end

    # points generated by (βᵢ, βᵢ, 0, 0, ...)
    @inbounds for i = 1:length(β)
        u = β[i]

        uh₁, uh₂, uh₃ = u * h₁, u * h₂, u * h₃
        p[1], p[3], p[5] = x₁ + uh₁, x₂ + uh₂, x₃ + uh₃
        p[2], p[4], p[6] = x₁ - uh₁, x₂ - uh₂, x₃ - uh₃

        s = f(p[1], p[3], x₃) + f(p[1], x₂, p[5]) + f(x₁, p[3], p[5]) +
            f(p[1], p[4], x₃) + f(p[1], x₂, p[6]) + f(x₁, p[3], p[6]) +
            f(p[2], p[3], x₃) + f(p[2], x₂, p[5]) + f(x₁, p[4], p[5]) +
            f(p[2], p[4], x₃) + f(p[2], x₂, p[6]) + f(x₁, p[4], p[6])

        I += wb[i][1] * s
    end

    # points generated by (ɛᵢ, ɛᵢ, ɛᵢ, 0, ...)
    @inbounds for i = 1:length(ɛ)
        u = ɛ[i]

        uh₁, uh₂, uh₃ = u * h₁, u * h₂, u * h₃
        p[1], p[3], p[5] = x₁ + uh₁, x₂ + uh₂, x₃ + uh₃
        p[2], p[4], p[6] = x₁ - uh₁, x₂ - uh₂, x₃ - uh₃

        s = zero(R)
        for l = 1:2, m = 1:2, n = 1:2
            s += f(p[l, 1], p[m, 2], p[n, 3])
        end

        I += wd[i][1] * s
    end

    # points generated by (ζᵢ, ζᵢ, ηᵢ, 0, ...)
    @inbounds for i = 1:length(ζ)
        u, v = ζ[i], η[i]

        uh₁, uh₂, uh₃ = u * h₁, u * h₂, v * h₃
        p[1], p[3], p[5] = x₁ + uh₁, x₂ + uh₂, x₃ + uh₃
        p[2], p[4], p[6] = x₁ - uh₁, x₂ - uh₂, x₃ - uh₃

        s = zero(R)
        for l = 1:2, m = 1:2, n = 1:2
            s += f(p[l, 1], p[m, 2], p[n, 3])
        end

        uh₂, uh₃ = v * h₂, u * h₃
        p[3], p[5] = x₂ + uh₂, x₃ + uh₃
        p[4], p[6] = x₂ - uh₂, x₃ - uh₃

        for l = 1:2, m = 1:2, n = 1:2
            s += f(p[l, 1], p[m, 2], p[n, 3])
        end

        uh₁, uh₂ = v * h₁, u * h₂
        p[1], p[3] = x₁ + uh₁, x₂ + uh₂
        p[2], p[4] = x₁ - uh₁, x₂ - uh₂

        for l = 1:2, m = 1:2, n = 1:2
            s += f(p[l, 1], p[m, 2], p[n, 3])
        end

        I += we[i][1] * s
    end

    return I * (h₁ * h₂ * h₃)
end

function weightedpoints!{F,R,T}(f::F, wp::WPoints{3,T,R},
                                r::Region{3,T,R}, p::MMatrix{2,3,T})
    x₁, x₂, x₃ = r.x
    h₁, h₂, h₃ = r.h

    V = h₁ * h₂ * h₃

    push!(wp, f(V * p₀[1], SVector(x₁, x₂, x₃)))

    # points generated by (αᵢ, 0, 0, 0, ...)
    @inbounds for i = 1:length(α)
        u = α[i]
        wᵢ = V * wa[i][1]

        uh₁, uh₂, uh₃ = u * h₁, u * h₂, u * h₃
        p[1], p[3], p[5] = x₁ + uh₁, x₂ + uh₂, x₃ + uh₃
        p[2], p[4], p[6] = x₁ - uh₁, x₂ - uh₂, x₃ - uh₃

        push!(wp, f(wᵢ, SVector(p[1], x₂, x₃)))
        push!(wp, f(wᵢ, SVector(p[2], x₂, x₃)))
        push!(wp, f(wᵢ, SVector(x₁, p[3], x₃)))
        push!(wp, f(wᵢ, SVector(x₁, p[4], x₃)))
        push!(wp, f(wᵢ, SVector(x₁, x₂, p[5])))
        push!(wp, f(wᵢ, SVector(x₁, x₂, p[6])))
    end

    # points generated by (βᵢ, βᵢ, 0, 0, ...)
    @inbounds for i = 1:length(β)
        u = β[i]
        wᵢ = V * wb[i][1]

        uh₁, uh₂, uh₃ = u * h₁, u * h₂, u * h₃
        p[1], p[3], p[5] = x₁ + uh₁, x₂ + uh₂, x₃ + uh₃
        p[2], p[4], p[6] = x₁ - uh₁, x₂ - uh₂, x₃ - uh₃

        push!(wp, f(wᵢ, SVector(p[1], p[3], x₃)))
        push!(wp, f(wᵢ, SVector(p[1], p[4], x₃)))
        push!(wp, f(wᵢ, SVector(p[2], p[3], x₃)))
        push!(wp, f(wᵢ, SVector(p[2], p[4], x₃)))
        push!(wp, f(wᵢ, SVector(p[1], x₂, p[5])))
        push!(wp, f(wᵢ, SVector(p[1], x₂, p[6])))
        push!(wp, f(wᵢ, SVector(p[2], x₂, p[5])))
        push!(wp, f(wᵢ, SVector(p[2], x₂, p[6])))
        push!(wp, f(wᵢ, SVector(x₁, p[3], p[5])))
        push!(wp, f(wᵢ, SVector(x₁, p[3], p[6])))
        push!(wp, f(wᵢ, SVector(x₁, p[4], p[5])))
        push!(wp, f(wᵢ, SVector(x₁, p[4], p[6])))
    end

    # points generated by (ɛᵢ, ɛᵢ, ɛᵢ, 0, ...)
    @inbounds for i = 1:length(ɛ)
        u = ɛ[i]
        wᵢ = V * wd[i][1]

        uh₁, uh₂, uh₃ = u * h₁, u * h₂, u * h₃
        p[1], p[3], p[5] = x₁ + uh₁, x₂ + uh₂, x₃ + uh₃
        p[2], p[4], p[6] = x₁ - uh₁, x₂ - uh₂, x₃ - uh₃

        for l = 1:2, m = 1:2, n = 1:2
            push!(wp, f(wᵢ, SVector(p[l, 1], p[m, 2], p[n, 3])))
        end
    end

    # points generated by (ζᵢ, ζᵢ, ηᵢ, 0, ...)
    @inbounds for i = 1:length(ζ)
        u, v = ζ[i], η[i]
        wᵢ = V * we[i][1]

        uh₁, uh₂, uh₃ = u * h₁, u * h₂, v * h₃
        p[1], p[3], p[5] = x₁ + uh₁, x₂ + uh₂, x₃ + uh₃
        p[2], p[4], p[6] = x₁ - uh₁, x₂ - uh₂, x₃ - uh₃

        for l = 1:2, m = 1:2, n = 1:2
            push!(wp, f(wᵢ, SVector(p[l, 1], p[m, 2], p[n, 3])))
        end

        uh₂, uh₃ = v * h₂, u * h₃
        p[3], p[5] = x₂ + uh₂, x₃ + uh₃
        p[4], p[6] = x₂ - uh₂, x₃ - uh₃

        for l = 1:2, m = 1:2, n = 1:2
            push!(wp, f(wᵢ, SVector(p[l, 1], p[m, 2], p[n, 3])))
        end

        uh₁, uh₂ = v * h₁, u * h₂
        p[1], p[3] = x₁ + uh₁, x₂ + uh₂
        p[2], p[4] = x₁ - uh₁, x₂ - uh₂

        for l = 1:2, m = 1:2, n = 1:2
            push!(wp, f(wᵢ, SVector(p[l, 1], p[m, 2], p[n, 3])))
        end
    end

    return nothing
end

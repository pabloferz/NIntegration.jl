#!/usr/bin/env julia

### Test suite for NIntegration.jl

using NIntegration
using Base.Test

### Tests

@time @testset "Integration" begin include("integration.jl") end

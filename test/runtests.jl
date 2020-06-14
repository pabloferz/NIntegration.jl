#!/usr/bin/env julia

### Test suite for NIntegration.jl

using NIntegration
using Test

### Tests

@time @testset "Integration" begin include("integration.jl") end

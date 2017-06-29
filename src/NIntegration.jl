__precompile__()

module NIntegration


### Dependencies
using Compat
using DataStructures
using StaticArrays

### Implementation
path = dirname(realpath(@__FILE__)) # works even for symlinks
if VERSION < v"0.6.0"
    include(joinpath(path, "types-0.5.jl"))
else
    include(joinpath(path, "types.jl"))
end
include(joinpath(path, "rules.jl"))
include(joinpath(path, "utils.jl"))
include(joinpath(path, "integration.jl"))
include(joinpath(path, "3d.jl"))

### Exports
export nintegrate, weightedpoints, weights, points


end # module

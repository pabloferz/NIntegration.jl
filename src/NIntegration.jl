module NIntegration


### Dependencies
using DataStructures
using StaticArrays


### Implementation
path = dirname(realpath(@__FILE__)) # works even for symlinks
include(joinpath(path, "types.jl"))
include(joinpath(path, "rules.jl"))
include(joinpath(path, "utils.jl"))
include(joinpath(path, "integration.jl"))
include(joinpath(path, "3d.jl"))


### Exports
export nintegrate, weightedpoints, weights, points


end # module

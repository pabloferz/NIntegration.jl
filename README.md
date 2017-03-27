| **Build Status**                          | **Code Coverage**                              |
|:-----------------------------------------:|:----------------------------------------------:|
| [![Build Status][travis-img]][travis-url] | [![Coverage Status][coveral-img]][coveral-url] |
| [![Build Status][appvey-img]][appvey-url] | [![Coverage Status][codecov-img]][codecov-url] |


# NIntegration.jl

This is library intended to provided multidimensional numerical integration
routines in pure [Julia](http://julialang.org)

## Status

For the time being this library can only perform integrals in three dimensions.

**TODO**

- [ ] Add rules for other dimensions
- [ ] Parallelize

## Installation

`NIntegration.jl` should work on Julia 0.5 and later versions and can be
installed from a Julia session by running

```julia
julia> Pkg.clone("https://github.com/pabloferz/NIntegration.jl.git")
```

## Usage

Once installed, run

```julia
using NIntegration
```

To integrate a function `f(x, y, z)` on the
[hyperrectangle](https://en.wikipedia.org/wiki/Hyperrectangle) defined by
`xmin` and `xmax`, just call

```julia
nintegrate(f::Function, xmin::NTuple{N}, xmax::NTuple{N};
           reltol = 1e-6, abstol = eps(), maxevals = 1000000)
```

The above returns a tuple `(I, E, n, R)` of the calculated integral `I`, the
estimated error `E`, the number of integrand evaluations `n`, and a list `R` of
the subregions in which the integration domain was subdivided.

If you need to evaluate multiple functions `(f₁, f₂, ...)` on the same
integration domain, you can evaluate the function `f` with more "features" and
use its subregions list to estimate the integral for the rest of the functions
in the list, e.g.

```julia
(I, E, n, R) = nintegrate(f, xmin, xmin)
I₁ = nintegrate(f₁, R)
```

## Technical Algorithms and References

The integration algorithm is based on the one decribed in:

 * J. Berntsen, T. O. Espelid, and A. Genz, "An Adaptive Algorithm for the
   Approximate Calculation of Multiple Integrals," *ACM Trans. Math. Soft.*, 17
   (4), 437-451 (1991).

## Author

 * [Pablo Zubieta](https://github.com/pabloferz)

## Acknowdlegments

The author expresses his gratitude to [Professor Alan
Genz](http://www.math.wsu.edu/faculty/genz/homepage) for some useful pointers.



[//]: # (Links)

[travis-img]: https://travis-ci.org/pabloferz/NIntegration.jl.svg?branch=master
[travis-url]: https://travis-ci.org/pabloferz/NIntegration.jl

[appvey-img]: https://ci.appveyor.com/api/projects/status/a2ot9sej796hernj?svg=true
[appvey-url]: https://ci.appveyor.com/project/pabloferz/nintegration-jl

[coveral-img]: https://coveralls.io/repos/pabloferz/NIntegration.jl/badge.svg?branch=master&service=github
[coveral-url]: https://coveralls.io/github/pabloferz/NIntegration.jl?branch=master

[codecov-img]: http://codecov.io/github/pabloferz/NIntegration.jl/coverage.svg?branch=master
[codecov-url]: http://codecov.io/github/pabloferz/NIntegration.jl?branch=master

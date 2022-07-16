```@meta
CurrentModule = BackgroundMeshes
```

# BackgroundMeshes.jl

[![Code](https://img.shields.io/badge/Code-GitHub-black.svg)](https://github.com/JuliaAstro/BackgroundMeshes.jl)
[![Build Status](https://github.com/JuliaAstro/BackgroundMeshes.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaAstro/BackgroundMeshes.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![PkgEval](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/B/BackgroundMeshes.svg)](https://juliaci.github.io/NanosoldierReports/pkgeval_badges/report.html)
[![Coverage](https://codecov.io/gh/JuliaAstro/BackgroundMeshes.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaAstro/BackgroundMeshes.jl)
[![License](https://img.shields.io/github/license/JuliaAstro/BackgroundMeshes.jl?color=yellow)](https://github.com/JuliaAstro/BackgroundMeshes.jl/blob/main/LICENSE)

Create meshes for estimating the background in astronomical images. Originally a submodule of [Photometry.jl](https://github.com/JuliaAstro/Photometry.jl).

## Installation

Currently, this package is unregistered and must be installed directly from this repository using the built-in package manager

```julia
julia>]
pkg> add https://github.com/JuliaAstro/BackgroundMeshes.jl
```

```julia
julia> using Pkg; Pkg.add("https://github.com/JuliaAstro/BackgroundMeshes.jl")
```

To load this package

```julia
julia> using BackgroundMeshes
```

For more information, see the [Pkg documentation](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Contributing and Support

If you would like to contribute, feel free to open a [pull request](https://github.com/JuliaAstro/BackgroundMeshes.jl/pulls). If you want to discuss something before contributing, head over to [discussions](https://github.com/JuliaAstro/BackgroundMeshes.jl/discussions) and join or open a new topic. If you're having problems with something, please open an [issue](https://github.com/JuliaAstro/BackgroundMeshes.jl/issues).

## License

The work derived from [astropy/photutils](https://github.com/astropy/photutils) is BSD 3-clause. All other work uses the MIT license. Therefore, this work as a whole is BSD 3-clause. [`LICENSE`](https://github.com/JuliaAstro/BackgroundMeshes.jl/blob/main/LICENSE) contains all licenses and any files using derived work are noted at the top of the file.

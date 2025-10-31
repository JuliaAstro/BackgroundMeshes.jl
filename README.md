# BackgroundMeshes.jl
[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliaastro.org/BackgroundMeshes/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaAstro.github.io/BackgroundMeshes.jl/dev/)

[![CI](https://github.com/JuliaAstro/BackgroundMeshes.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/JuliaAstro/BackgroundMeshes.jl/actions/workflows/CI.yml)
[![Coverage](https://codecov.io/gh/JuliaAstro/BackgroundMeshes.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaAstro/BackgroundMeshes.jl)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-orange.svg)](https://opensource.org/licenses/BSD-3-Clause)

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

For more information, see the [Pkg documentation](https://docs.julialang.org/en/v1/stdlib/Pkg/).

## Usage

To load this package

```julia
julia> using BackgroundMeshes
```

Please see the [online documentation](https://juliaastro.github.io/BackgroundMeshes.jl/dev/) for further usage, tutorials, and API reference.

## Contributing and Support

If you would like to contribute, feel free to open a [pull request](https://github.com/JuliaAstro/BackgroundMeshes.jl/pulls). If you want to discuss something before contributing, head over to [discussions](https://github.com/JuliaAstro/BackgroundMeshes.jl/discussions) and join or open a new topic. If you're having problems with something, please open an [issue](https://github.com/JuliaAstro/BackgroundMeshes.jl/issues).

## License

The work derived from [astropy/photutils](https://github.com/astropy/photutils) is BSD 3-clause. All other work uses the MIT license. Therefore, this work as a whole is BSD 3-clause. [`LICENSE`](LICENSE) contains all licenses and any files using derived work are noted at the top of the file.

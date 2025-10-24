#=
Part of this work is derived from astropy/photutils and astropy/astropy. The relevant derivations
are considered under a BSD 3-clause license. =#

# Interpolator

"""
    BackgroundInterpolator

This abstract type embodies the different ways of converting a low-resolution mesh into a high-resolution image, especially for dispatch with [`estimate_background`](@ref)

To implement a new interpolation scheme, you must define the struct and define a method like `(::MyInterpolator)(mesh)`

# See Also
* [Interpolators](@ref)
"""
abstract type BackgroundInterpolator end

"""
    ZoomInterpolator(factors)

Use a cubic-spline interpolation scheme to increase resolution of a mesh.

`factors` represents the level of "zoom", so an input mesh of size `(10, 10)` with factors `(2, 2)` will have an output size of `(20, 20)`. If only an integer is provided, it will be used as the factor for every axis.

# Examples
```jldoctest
julia> ZoomInterpolator(2)([1 0; 0 1])
4×4 Matrix{Float64}:
  1.0          0.75   0.25   -2.77556e-17
  0.75         0.625  0.375   0.25
  0.25         0.375  0.625   0.75
 -5.55112e-17  0.25   0.75    1.0

julia> ZoomInterpolator(3, 1)([1 0; 0 1])
6×2 Matrix{Float64}:
  1.0          -2.77556e-17
  1.0          -2.77556e-17
  0.666667      0.333333
  0.333333      0.666667
 -5.55112e-17   1.0
 -5.55112e-17   1.0

```
"""
@concrete struct ZoomInterpolator{F<:NTuple{2,<:Integer}} <: BackgroundInterpolator
    factors::F
end

ZoomInterpolator(factor::Integer) = ZoomInterpolator((factor, factor))
ZoomInterpolator(f1::Integer, args...) = ZoomInterpolator((f1, args...))

function (z::ZoomInterpolator)(mesh::AbstractArray{T}) where {T}
    itp = cubic_spline_interpolation(axes(mesh), mesh)
    out = similar(mesh, float(T), size(mesh) .* z.factors)
    return imresize!(out, itp)
end

"""
    IDWInterpolator(factors; leafsize=10, k=8, power=1, reg=0, conf_dist=1e-12)

Use Shepard Inverse Distance Weighing interpolation scheme to increase resolution of a mesh.

`factors` represents the level of "zoom", so an input mesh of size `(10, 10)` with factors `(2, 2)` will have an output size of `(20, 20)`. If only an integer is provided, it will be used as the factor for every axis.

The interpolator can be called with some additional parameters:
- `leaf_size` determines at what number of points to stop splitting the tree further,
- `k` which is the number of nearest neighbors to be considered,
- `power` is the exponent for distance in the weighing factor,
- `reg` is the offset for the weighing factor in denominator,
- `conf_dist` is the distance below which two points would be considered as the same point.


# Examples
```jldoctest
julia> IDWInterpolator(2, k=2)([1 0; 0 1])
4×4 Matrix{Float64}:
 1.0   0.75      0.25      0.0
 0.75  0.690983  0.309017  0.25
 0.25  0.309017  0.690983  0.75
 0.0   0.25      0.75      1.0

julia> IDWInterpolator(3, 1; k=2, power=4)([1 0; 0 1])
6×2 Matrix{Float64}:
 1.0        0.0
 1.0        0.0
 0.941176   0.0588235
 0.0588235  0.941176
 0.0        1.0
 0.0        1.0
```
"""
@concrete struct IDWInterpolator{F<:NTuple{2,<:Integer},K<:Integer} <: BackgroundInterpolator
    factors::F
    leafsize::K
    k::K
    power
    reg
    conf_dist
end

function IDWInterpolator(factors;
    leafsize = 10,
    k = 8,
    power = 1.0,
    reg = 0.0,
    conf_dist = 1e-12,
    )
    return IDWInterpolator(factors, leafsize, k, power, reg, conf_dist)
end
# convenience constructors
IDWInterpolator(factor::Integer; kwargs...) = IDWInterpolator((factor, factor); kwargs...)
IDWInterpolator(factor::Integer, args...; kwargs...) = IDWInterpolator((factor, args...); kwargs...)

function (IDW::IDWInterpolator)(mesh::AbstractArray{T}) where {T}
    knots = Array{float(T)}(undef, 2, length(mesh))
    idxs = CartesianIndices(mesh)
    for (i, idx) in enumerate(idxs)
        @inbounds @views knots[:, i] .= idx.I
    end

    itp = ShepardIDWInterpolator(knots, float(mesh);
        IDW.leafsize,
        IDW.k,
        IDW.power,
        IDW.reg,
        IDW.conf_dist,
    )
    out = similar(mesh, float(T), size(mesh) .* IDW.factors)
    return imresize!(out, itp)
end

###############################################################################
# Interface with Interpolations.jl

struct IDW <: InterpolationType end

struct ShepardIDWInterpolator{
    T<:AbstractFloat,
    N,
    KD<:KDTree{<:AbstractVector,<:MinkowskiMetric,T},
    K<:Integer,
    P,
    R,
    C,
    } <: AbstractInterpolation{T,N,IDW}
    values::Array{T,N}
    tree::KD
    k::K
    power::P
    reg::R
    conf_dist::C
end

#= Warning! These are not accurate for use as a standard interpolator,
   but are what we need for our use with images =#
Base.axes(itp::ShepardIDWInterpolator) = axes(itp.values)
Base.size(itp::ShepardIDWInterpolator) = size(itp.values)

function ShepardIDWInterpolator(
    knots::AbstractArray,
    values::AbstractArray;
    leafsize::Integer=10,
    k::Integer=8,
    power = 1,
    reg = 0,
    conf_dist = 1e-12,
)
    if length(values) < k
        throw(
            ArgumentError(
                "k ($k) must be less than or equal to the number of points ($(length(values))).",
            ),
        )
    end
    tree = KDTree(knots; leafsize)
    return ShepardIDWInterpolator(values, tree, k, power, reg, conf_dist)
end

function (itp::ShepardIDWInterpolator{T})(points...) where {T}

    # find the n-closest indices and distances
    idxs, dist = knn(itp.tree, vcat(points...), itp.k, true)

    # If our first point is less than `conf_dist` away from an existing point, use that instead
    first(dist) ≤ itp.conf_dist && return itp.values[first(idxs)]

    # no-allocation loop calculating using Shepard's scheme
    num = den = zero(T)
    @inbounds for (i, d) in zip(idxs, dist)
        w = 1 / (itp.reg + d^itp.power)
        num += w * itp.values[i]
        den += w
    end

    return num / den
end

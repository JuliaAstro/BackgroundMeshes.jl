#=
Part of this work is derived from astropy/photutils and astropy/astropy. The relevant derivations
are considered under a BSD 3-clause license. =#

using StatsBase: mad
using Statistics
using BiweightStats

###############################################################################
# Abstract types

"""
    BackgroundMeshes.LocationEstimator

This abstract type embodies the possible background estimation algorithms for dispatch with [`estimate_background`](@ref).

To implement a new estimator, you must define the struct and define a method like `(::MyEstimator)(data::AbstractArray; dims=:)`.

# See Also
* [Location Estimators](@ref Location-Estimators-API)
"""
abstract type LocationEstimator end

"""
    BackgroundMeshes.RMSEstimator

This abstract type embodies the possible background RMS estimation algorithms for dispatch with [`estimate_background`](@ref).

To implement a new estimator, you must define the struct and define a method like `(::MyRMSEstimator)(data::AbstractArray; dims=:)`.

# See Also
* [RMS Estimators](@ref RMS-Estimators-API)
"""
abstract type RMSEstimator end

########################################################################
# Location estimators

"""
    SourceExtractorBackground()

This estimator returns the background of the input using the SourceExtractorBackground algorithm.

The background is calculated using a mode estimator of the form `(2.5 * median) - (1.5 * mean)`.

If `(mean - median) / std > 0.3` then the median is used and if `std = 0` then the mean is used.

# Examples
```jldoctest
julia> data = ones(3, 5);

julia> SourceExtractorBackground()(data)
1.0

julia> SourceExtractorBackground()(data, dims=1)
1×5 Matrix{Float64}:
 1.0  1.0  1.0  1.0  1.0
```
"""
struct SourceExtractorBackground <: LocationEstimator end

""" Utility function for SourceExtractorBackground algorithm"""
function validate_SE(background, _mean, _median, _std)
    _std ≈ 0 && return _mean
    abs(_mean - _median) / _std > 0.3 && return _median
    return background
end

function (::SourceExtractorBackground)(data; dims = :)
    _mean = mean(data; dims)
    _median = median(data; dims)
    _std = std(data; dims)

    background = @. 2.5 * _median - 1.5 * _mean
    return validate_SE.(background, _mean, _median, _std)
end

"""
    MMMBackground(median_factor=3, mean_factor=2)

Estimate the background using a mode estimator of the form `median_factor * median - mean_factor * mean`.
This algorithm is based on the `MMMBackground` routine originally implemented in DAOPHOT. `MMMBackground` uses factors of `median_factor=3` and `mean_factor=2` by default.
This estimator assumes that contaminated sky pixel values overwhelmingly display positive departures from the true value.

# Examples
```jldoctest
julia> x = ones(3, 5);

julia> MMMBackground()(x)
1.0

julia> MMMBackground(median_factor=4, mean_factor=3)(x, dims = 1)
1×5 Matrix{Float64}:
 1.0  1.0  1.0  1.0  1.0
```

# See Also
* [`SourceExtractorBackground`](@ref)
"""
Base.@kwdef struct MMMBackground{T,V} <: LocationEstimator
    median_factor::T = 3
    mean_factor::V = 2
end

function (alg::MMMBackground)(data; dims = :)
    _median = median(data; dims)
    _mean = mean(data; dims)
    return @. alg.median_factor * _median - alg.mean_factor * _mean
end

"""
    BiweightLocationBackground(c = 6.0, M = nothing)

Estimate the background using the robust biweight location statistic.

See [BiweightStats.jl](https://github.com/mileslucas/BiweightStats.jl) for more information.

# Examples
```jldoctest
julia> x = ones(3,5);

julia> BiweightLocationBackground()(x)
1.0

julia> BiweightLocationBackground(c=5.5)(x; dims = 1)
1×5 Matrix{Float64}:
 1.0  1.0  1.0  1.0  1.0
```
"""
Base.@kwdef struct BiweightLocationBackground{T,V} <: LocationEstimator
    c::T = 6
    M::V = nothing
end

(alg::BiweightLocationBackground)(data; dims=:) = location(data; dims, alg.c, alg.M)

########################################################################
# RMS Estimators

"""
    StdRMS()

Uses the standard deviation statistic for background RMS estimation.

# Examples
```jldoctest
julia> data = ones(3, 5);

julia> StdRMS()(data)
0.0

julia> StdRMS()(data, dims=1)
1×5 Matrix{Float64}:
 0.0  0.0  0.0  0.0  0.0
```
"""
struct StdRMS <: RMSEstimator end

(::StdRMS)(data; dims = :) = std(data; corrected = false, dims)

"""
    MADStdRMS()

Uses the standard median absolute deviation (MAD) statistic for background RMS estimation.

This is typically given as

``\\sigma \\approx 1.4826 \\cdot \\text{MAD}``

# Examples
```jldoctest
julia> data = ones(3, 5);

julia> MADStdRMS()(data)
0.0

julia> MADStdRMS()(data, dims=1)
1×5 Matrix{Float64}:
 0.0  0.0  0.0  0.0  0.0
```
"""
struct MADStdRMS <: RMSEstimator end

_mad(data, ::Colon) = mad(data; normalize = true)
_mad(data, dims) = mapslices(x -> mad(x; normalize=true), data; dims)
(::MADStdRMS)(data; dims = :) = _mad(data, dims)

"""
    BiweightScaleRMS(c=9.0, M=nothing)

Uses the robust biweight scale statistic for background RMS estimation.

The biweight scale is the square root of the biweight midvariance. The biweight midvariance uses a tuning constant, `c`, and an optional initial guess of the central value `M`.

See [BiweightStats.jl](https://github.com/mileslucas/BiweightStats.jl) for more information.

# Examples
```jldoctest
julia> data = ones(3, 5);

julia> BiweightScaleRMS()(data)
0.0

julia> BiweightScaleRMS(c=3.0)(data, dims=1)
1×5 Matrix{Float64}:
 0.0  0.0  0.0  0.0  0.0
```
"""
Base.@kwdef struct BiweightScaleRMS{T,V} <: RMSEstimator
    c::T = 9.0
    M::V = nothing
end

(alg::BiweightScaleRMS)(data; dims=:) = scale(data; dims, alg.c, alg.M)

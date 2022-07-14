using BackgroundMeshes
using StableRNGs
using Statistics
using Test

rng = StableRNG(659929)

@testset "BackgroundMeshes.jl" begin
    include("background.jl")
    include("estimators.jl")
    include("interpolators.jl")
end

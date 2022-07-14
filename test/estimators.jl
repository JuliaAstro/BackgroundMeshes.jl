using BiweightStats
using StatsBase: mad

###############################################################################
# Location Estimators

@testset "Trivial $E" for E in [
    MMMBackground, SourceExtractorBackground, BiweightLocationBackground
]
    estimator = E()

    @test estimator(ones(1)) == 1

    data = ones(10, 10)

    @test estimator(data) ≈ 1.0
    @test estimator(data; dims=1) ≈ ones(1, 10)
    @test estimator(data; dims=2) ≈ ones(10)

    data = zeros(10, 10)

    @test estimator(data) ≈ 0.0
    @test estimator(data; dims=1) ≈ zeros(1, 10)
    @test estimator(data; dims=2) ≈ zeros(10)

    data = randn(rng, 100, 100)

    @test estimator(data) ≈ 0.0 atol = 1e-2
    @test estimator(data; dims=1) ≈ zeros(1, 10) atol = 1e-2
    @test estimator(data; dims=2) ≈ zeros(10) atol = 1e-2
end

@testset "SourceExtractorBackground" begin
    # test skewed distribution
    data = float(collect(1:100))
    data[71:end] .= 1e7

    @test SourceExtractorBackground()(data) ≈ median(data)
end

@testset "BiweightLocationBackground" begin
    b = BiweightLocationBackground()
    X = [1, 3, 5, 500, 2]
    @test b(X) ≈ location(X) atol = 1e-3
end

###############################################################################
# RMS Estimators

@testset "Trivial $E" for E in [StdRMS, MADStdRMS, BiweightScaleRMS]
    estimator = E()

    @test estimator(ones(1)) == 0

    data = ones(10, 10)
    @test estimator(data) ≈ 0.0
    @test estimator(data; dims=1) ≈ zeros(1, 10)
    @test estimator(data; dims=2) ≈ zeros(10)

    data = randn(rng, 10000, 10000)
    @test estimator(data) ≈ 1 atol = 3e-2
    @test estimator(data; dims=1) ≈ ones(1, 10) atol = 1e-2
    @test estimator(data; dims=2) ≈ ones(10) atol = 1e-2
end

@testset "StdRMS" begin
    s = StdRMS()
    data = randn(rng, 100)
    @test s(data) == std(data; corrected=false)
end

@testset "MADStdRMS" begin
    s = MADStdRMS()
    data = randn(rng, 100)
    @test s(data) == mad(data; normalize=true)
end

@testset "BiweightScaleRMS" begin
    s = BiweightScaleRMS()
    X = [1, 3, 5, 500, 2]
    @test s(X) ≈ scale(X)
end

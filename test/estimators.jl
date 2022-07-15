using BiweightStats
using StatsBase: mad

###############################################################################
# Location Estimators

@testset "Trivial $estimator" for estimator in (
    mean, median, MMMBackground(), SourceExtractorBackground(), BiweightLocationBackground()
)
    frame_size = (1000, 1000)

    @test estimator(ones(1)) == 1
    ## Flat ones
    data = ones(frame_size)
    @test all(d -> isapprox(d, 1), estimator(data))

    # along each dimension
    res = estimator(data; dims=1)
    @test size(res) == (1, frame_size[2])
    @test all(d -> isapprox(d, 1), res)

    res = estimator(data; dims=2)
    @test size(res) == (frame_size[1], 1)
    @test all(d -> isapprox(d, 1), res)

    ## Flat zeros
    data = zeros(frame_size)
    @test all(d -> isapprox(d, 0; atol=1e-2), estimator(data))

    # along each dimension
    res = estimator(data; dims=1)
    @test size(res) == (1, frame_size[2])
    @test all(d -> isapprox(d, 0; atol=1e-2), res)

    res = estimator(data; dims=2)
    @test size(res) == (frame_size[1], 1)
    @test all(d -> isapprox(d, 0; atol=1e-2), res)

    ## Random data
    data = randn(rng, frame_size)
    @test all(d -> isapprox(d, 0; atol=10/sqrt(prod(frame_size))), estimator(data))

    # along each dimension
    res = estimator(data; dims=1)
    @test size(res) == (1, frame_size[2])
    @test all(d -> isapprox(d, 0; atol=10/sqrt(frame_size[1])), res)

    res = estimator(data; dims=2)
    @test size(res) == (frame_size[1], 1)
    @test all(d -> isapprox(d, 0; atol=10/sqrt(frame_size[2])), res)
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
    @test b(X) ≈ location(X; c=b.c)
end

###############################################################################
# RMS Estimators

@testset "Trivial $estimator" for estimator in (StdRMS(), MADStdRMS(), BiweightScaleRMS())
    frame_size = (1000, 1000)

    @test estimator(ones(1)) == 0
    ## Flat data
    data = ones(frame_size)
    @test all(d -> isapprox(d, 0; atol=1e-2), estimator(data))

    # along each dimension
    res = estimator(data; dims=1)
    @test size(res) == (1, frame_size[2])
    @test all(d -> isapprox(d, 0; atol=1e-2), res)

    res = estimator(data; dims=2)
    @test size(res) == (frame_size[1], 1)
    @test all(d -> isapprox(d, 0; atol=1e-2), res)

    ## random data
    data = randn(rng, frame_size)
    @test all(d -> isapprox(d, 1; atol=10/sqrt(prod(frame_size))), estimator(data))

    # along each dimension
    res = estimator(data; dims=1)
    @test size(res) == (1, frame_size[2])
    @test all(d -> isapprox(d, 1; atol=10/sqrt(frame_size[1])), res)

    res = estimator(data; dims=2)
    @test size(res) == (frame_size[1], 1)
    @test all(d -> isapprox(d, 1; atol=10/sqrt(frame_size[2])), res)
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
    @test s(X) ≈ scale(X; c=s.c)
end

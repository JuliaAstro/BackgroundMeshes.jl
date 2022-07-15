using BackgroundMeshes: ShepardIDWInterpolator

@testset "IDWInterpolator" begin
    itp = @inferred IDWInterpolator((2, 3); k=4)
    @test @inferred(itp(ones(3, 2))) == ones(6, 6)
    @test IDWInterpolator(2)(ones(3, 4)) == IDWInterpolator((2, 2))(ones(3, 4))
    @test_throws ArgumentError IDWInterpolator(2)(ones(3, 2))

    # interface
    @test IDWInterpolator((2, 3)) == IDWInterpolator(2, 3)
    @test IDWInterpolator((2, 3); k=4) == IDWInterpolator(2, 3; k=4)
end

@testset "ShepardIDWInterpolator" begin
    # 1D
    x = rand(rng, 100)
    y = sin.(x)
    it = ShepardIDWInterpolator(x', y)
    @test @inferred(it(0.4)) ≈ sin(0.4) atol = 1e-1
    @test it.(0.2:0.1:0.5) ≈ sin.(0.2:0.1:0.5) atol = 1e-1

    # 2D
    x = rand(rng, 2, 10000)
    y = sin.(x[1, :] .+ x[2, :])
    it = ShepardIDWInterpolator(x, y)
    @test it(0.5, 0.6) ≈ sin(0.5 + 0.6) atol = 1e-2

    # interface

    #= Warning! These are not accurate for use as a standard interpolator,
       but are what we need for our use with images =#
    @test size(it) == (size(x, 2),)
    @test axes(it) == axes(y)
end

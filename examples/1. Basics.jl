#=
# 1. Basics

Let's dig into the basics of how these background meshes work. Let's start by creating some data.
For this image, I'll create a 2-D polynomial gradient across a 1000x1000 image.
=#
using AstroImages
using BackgroundMeshes
using Random
using Statistics
using Plots
rng = Random.seed!(125512)

xs = range(0, 1, length=1000)
ys = xs'
data = xs .* ys
implot(data)

#=
## Mesh size

Background meshes are defined by a grid of sub-images across the original data. Within these sub-images we use various statistics to estimate the background signal. Here we show directly how the sub-image size (i.e., mesh size) affects the background estimation
=#

box_sizes = (10, 50, 100)
backgrounds = map(n -> estimate_background(data, n; location=mean) |> first, box_sizes)
plot(
    implot(backgrounds[1], title="N=10", cbar=false),
    implot(backgrounds[2], title="N=50", cbar=false),
    implot(backgrounds[3], title="N=100", cbar=false),
    layout=(1, 3),
)


#=
## Location Estimators

As mentioned above, statistics are calculated inside each of the sub-images. Depending on your workflow and data quality, you can choose between a variety of estimators

1. `mean` or `median` from Statistics
2. [`SourceExtractorBackground`](@ref)
3. [`MMMBackground`](@ref)
4. [`BiweightLocationBackground`](@ref)

See the [`LocationEstimator`](@ref) docs for more information about each estimator. Let's create some data with outliers and look at how each estimator handles the outliers
=#
true_background = 10
sub_img = randn(rng, 100, 100) .+ true_background
## add in hot pixels
x_idxs = rand(rng, axes(sub_img, 1), 50)
y_idxs = rand(rng, axes(sub_img, 2), 50)
for (x, y) in zip(x_idxs, y_idxs)
    sub_img[x, y] = 2^16
end
implot(sub_img, clims=zscale(sub_img))

# now, how does each estimator compare

bkgs = [
    "mean" => mean(sub_img),
    "median" => median(sub_img),
    "source extractor" => SourceExtractorBackground()(sub_img),
    "MMM" => MMMBackground()(sub_img),
    "biweight location" => BiweightLocationBackground()(sub_img)
]
scatter(first.(bkgs), last.(bkgs), lab="")
hline!([true_background], c=:black, ls=:dash, lab="true value")
#=

here we see that `median` and [`BiweightLocationBackground`](@ref) do a good job of estimating the background despite the outliers, however the outliers can be removed ahead of time with a tool like [LACosmic.jl](https://github.com/JuliaAstro/LACosmic.jl).

## RMS Estimators

Within each sub-image we also calulate the root-mean-square (RMS) estimate of noise, which can be forward propagated in your analysis.

1. [`StdRMS`](@ref)
2. [`MADStdRMS`](@ref)
3. [`BiweightScaleRMS`](@ref)

See the [`RMSEstimator`](@ref) docs for more information about each estimator. Let's create some data with outliers and look at how each estimator handles the outliers
=#

## use same data before N(10, 1)
true_rms = 1
rmss = [
    "std" => StdRMS()(sub_img),
    "MAD" => MADStdRMS()(sub_img),
    "biweight scale" => BiweightScaleRMS()(sub_img)
]
scatter(first.(rmss), last.(rmss), lab="")
hline!([true_rms], c=:black, ls=:dash, lab="true value")

#=
again, we see the median-based [`MADStdRMS`](@ref) as well as the [`BiweightScaleRMS`](@ref) do well despite the outliers.
=#

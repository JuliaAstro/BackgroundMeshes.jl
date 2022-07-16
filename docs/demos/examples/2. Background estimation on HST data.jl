using AstroImages
using BackgroundMeshes
using FITSIO
using Plots

# Download our image, courtesy of astropy
file = download("https://rawcdn.githack.com/astropy/photutils-datasets/8c97b4fa3a6c9e6ea072faeed2d49a20585658ba/data/M6707HH.fits")
image = AstroImage(file)
implot(image, cmap=:magma, xrotation=45)


#=
Now let's try and estimate the background using [`estimate_background`](@ref). First, we'll sigma-clip to try and remove the signals from the stars. Then, the background is broken down into boxes, in this case of size `(50, 50)`. Within each box, the given statistical estimators get the background value and RMS. By default, we use [`SourceExtractorBackground`](@ref) and [`StdRMS`](@ref). This creates a low-resolution image, which we then need to resize. We can accomplish this using an interpolator, by default a cubic-spline interpolator via [`ZoomInterpolator`](@ref). The end result is a smooth estimate of the spatially varying background and background RMS.
=#
    
## sigma-clip
clipped = sigma_clip(image, 1, fill=NaN)
## get background and background rms with box-size (50, 50)
bkg, bkg_rms = estimate_background(clipped, 50)
## plot
plot(
    implot(image, title="Original"),
    implot(clipped, title="Sigma-Clipped"),
    implot(bkg, title="Background"),
    implot(bkg_rms, title="Background RMS");
    cmap=:magma, layout=(2, 2), ticks=false
)

# We could apply a median filter, too, by specifying `filter_size`

## get background and background rms with box-size (50, 50) and filter_size (5, 5)
bkg_f, bkg_rms_f = estimate_background(clipped, 50, filter_size=5)
## plot
plot(
    implot(bkg, title="Unfiltered", ylabel="Background"),
    implot(bkg_f, title="Filtered"),
    implot(bkg_rms, ylabel="RMS"),
    implot(bkg_rms_f);
    layout=(2, 2), ticks=false
)

    
# Now we can see our image after subtracting the filtered background and ready for further analysis!

subt = image .- bkg_f[axes(image)...]
## plot
plot(
    implot(image, title="Original", clims=(minimum(subt), maximum(image))),
    implot(subt, title="Subtracted", clims=(minimum(subt), maximum(image)));
    layout=(1, 2), size=(600, 260),
    xlims=(400, 800), ylims=(400, 800), 
    ticks=false, aspect_ratio=1
)

# ## IDW Interpolator
# Here is a quick example using the [`IDWInterpolator`](@ref)

b1, r1 = estimate_background(clipped, 50, filter_size=5)
b2, r2 = estimate_background(clipped, 50, itp=IDWInterpolator(50), filter_size=5)
## plot
plot(
    implot(b1, title="ZoomInterpolator", ylabel="Background"),
    implot(b2, title="IDWInterpolator"),
    implot(r1, ylabel="RMS"),
    implot(r2);
    layout=(2, 2), ticks=false
)

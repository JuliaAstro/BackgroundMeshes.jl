# API/Reference

```@index
```

## General

```@docs
estimate_background
sigma_clip
sigma_clip!
```


## Background Estimators

All of these estimators are subtypes of [`BackgroundMeshes.LocationEstimator`](@ref) or [`BackgroundMeshes.RMSEstimator`](@ref) and are derived using various statistical and image processing methods.

### Location Estimators

These estimators are used for estimating the background using some form of a central statistic.

```@docs
BackgroundMeshes.LocationEstimator
MMMBackground
SourceExtractorBackground
BiweightLocationBackground
```

### RMS Estimators

These estimators are used for estimating the root-mean-square (RMS) of the background using some form of a deviation statistic.

```@docs
BackgroundMeshes.RMSEstimator
StdRMS
MADStdRMS
BiweightScaleRMS
```

## Background Interpolators

Background interpolators provide a method for converting a low-resolution mesh into a low-order high-resolution image.

```@docs
BackgroundMeshes.BackgroundInterpolator
```

### Interpolators

```@docs
ZoomInterpolator
IDWInterpolator
```

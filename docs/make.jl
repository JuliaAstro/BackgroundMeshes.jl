using BackgroundMeshes
using DemoCards
using Documenter

# DemoCards: setup
examples, postprocess_cb, demo_assets = makedemos("demos")
assets = String[]
isnothing(demo_assets) || (push!(assets, demo_assets))

DocMeta.setdocmeta!(
    BackgroundMeshes, :DocTestSetup, :(using BackgroundMeshes); recursive=true
)

makedocs(;
    modules=[BackgroundMeshes],
    authors="Miles Lucas <mdlucas@hawaii.edu> and contributors",
    repo="https://github.com/JuliaAstro/BackgroundMeshes.jl/blob/{commit}{path}#{line}",
    sitename="BackgroundMeshes.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaAstro.github.io/BackgroundMeshes.jl",
        edit_link="main",
        assets=assets,
    ),
    pages=["Home" => "index.md", examples, "API/Reference" => "api.md"],
)

# DemoCards: postprocess
postprocess_cb()

deploydocs(; repo="github.com/JuliaAstro/BackgroundMeshes.jl", devbranch="main")

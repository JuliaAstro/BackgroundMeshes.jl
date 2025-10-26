using BackgroundMeshes
using Documenter
using Documenter.Remotes: GitHub

setup = quote
    using BackgroundMeshes
    using StableRNGs
    rng = StableRNG(1)
end

DocMeta.setdocmeta!(BackgroundMeshes, :DocTestSetup, setup; recursive=true)

pages = [
    "Home" => "index.md",
    "Examples" => map(Base.Fix1(joinpath, "examples"), ["1_basics.md", "2_background_estimation.md"]),
    "API/Reference" => "api.md",
]

makedocs(;
    modules = [BackgroundMeshes],
    authors = "Miles Lucas <mdlucas@hawaii.edu> and contributors",
    repo = GitHub("JuliaAstro/BackgroundMeshes.jl"),
    sitename = "BackgroundMeshes.jl",
    format = Documenter.HTML(;
        prettyurls = true,
        canonical = "https://JuliaAstro.github.io/BackgroundMeshes.jl",
        edit_link = "main",
    ),
    pages,
    checkdocs = :exports,
)

# CI only: deploy docs
in_CI_env = get(ENV, "CI", "false") == "true"
if in_CI_env
    deploydocs(;
        repo = "github.com/JuliaAstro/BackgroundMeshes.jl",
        push_preview = true,
        devbranch = "main",
    )
end

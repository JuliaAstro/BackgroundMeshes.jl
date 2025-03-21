using BackgroundMeshes
using Documenter
using Documenter.Remotes: GitHub
using Literate: markdown

# preprocess tutorials using Literate
srcdir = abspath(joinpath(@__DIR__, "..", "examples"))
outdir = abspath(joinpath(@__DIR__, "src"))

examples = map(Iterators.filter(endswith(".jl"), readdir(srcdir; join=true))) do file
    markdown(file, outdir)
    return replace(basename(file), ".jl" => ".md")
end

# regular documenter process
DocTestSetup = quote
    using BackgroundMeshes
    using StableRNGs
    rng = StableRNG(1)
end
DocMeta.setdocmeta!(BackgroundMeshes, :DocTestSetup, DocTestSetup; recursive=true)

pages = [
    "Home" => "index.md",
    "Examples" => examples,
    "API/Reference" => "api.md",
]

makedocs(;
    modules = [BackgroundMeshes],
    authors = "Miles Lucas <mdlucas@hawaii.edu> and contributors",
    repo = GitHub("JuliaAstro/BackgroundMeshes.jl"),
    sitename = "BackgroundMeshes.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://JuliaAstro.github.io/BackgroundMeshes.jl",
        edit_link = "main",
        assets = String[],
    ),
    pages,
    checkdocs = :exports,
)

# clean up markdown files generated by Literate
map(f -> rm(joinpath(outdir, f)), examples)

# CI only: deploy docs
deploydocs(; repo="github.com/JuliaAstro/BackgroundMeshes.jl", devbranch="main")

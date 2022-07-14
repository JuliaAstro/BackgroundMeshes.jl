using BackgroundMeshes
using Documenter

DocMeta.setdocmeta!(BackgroundMeshes, :DocTestSetup, :(using BackgroundMeshes);
                    recursive = true)

makedocs(;
         modules = [BackgroundMeshes],
         authors = "Miles Lucas <mdlucas@hawaii.edu> and contributors",
         repo = "https://github.com/JuliaAstro/BackgroundMeshes.jl/blob/{commit}{path}#{line}",
         sitename = "BackgroundMeshes.jl",
         format = Documenter.HTML(;
                                  prettyurls = get(ENV, "CI", "false") == "true",
                                  canonical = "https://JuliaAstro.github.io/BackgroundMeshes.jl",
                                  edit_link = "main",
                                  assets = String[]),
         pages = [
             "Home" => "index.md",
             "API/Reference" => "api.md",
         ])

deploydocs(;
           repo = "github.com/JuliaAstro/BackgroundMeshes.jl",
           devbranch = "main")

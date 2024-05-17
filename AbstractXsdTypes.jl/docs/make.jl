using AbstractXsdTypes
using Documenter

DocMeta.setdocmeta!(AbstractXsdTypes, :DocTestSetup, :(using AbstractXsdTypes); recursive = true)

makedocs(;
    modules = [AbstractXsdTypes],
    authors = "ASML",
    repo = "https://github.com/ASML-Labs/XmlStructTools.jl/AbstractXsdTypes.jl/blob/{commit}{path}#{line}",
    sitename = "AbstractXsdTypes.jl",
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", "false") == "true", edit_link = "main", assets = String[]),
    pages = ["Home" => "index.md", "Docstrings" => "docstrings.md"],
)

deploydocs(repo = "github.com/ASML-Labs/XmlStructTools.jl/AbstractXsdTypes.jl.git")

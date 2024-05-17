using XmlStructLoader
using Documenter

DocMeta.setdocmeta!(XmlStructLoader, :DocTestSetup, :(using XmlStructLoader); recursive = true)

makedocs(;
    modules = [XmlStructLoader],
    authors = "ASML",
    repo = "https://github.com/ASML-Labs/XmlStructTools.jl/XmlStructLoader.jl/blob/{commit}{path}#{line}",
    sitename = "XmlStructLoader.jl",
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", "false") == "true", edit_link = "main", assets = String[]),
    pages = ["Home" => "index.md", "Docstrings" => "docstrings.md"],
)

deploydocs(repo = "github.com/ASML-Labs/XmlStructTools.jl/XmlStructLoader.jl.git")

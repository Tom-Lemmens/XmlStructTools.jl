using XsdToStruct
using Documenter

DocMeta.setdocmeta!(XsdToStruct, :DocTestSetup, :(using XsdToStruct); recursive = true)

makedocs(;
    modules = [XsdToStruct],
    authors = "ASML",
    repo = "https://github.com/ASML-Labs/XmlStructTools.jl/XsdToStruct.jl/blob/{commit}{path}#{line}",
    sitename = "XsdToStruct.jl",
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", "false") == "true", edit_link = "main", assets = String[]),
    pages = ["Home" => "index.md", "Docstrings" => "docstrings.md"],
)

deploydocs(repo = "github.com/ASML-Labs/XmlStructTools.jl/XsdToStruct.jl.git")

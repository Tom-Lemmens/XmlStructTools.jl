using XmlStructWriter
using Documenter

DocMeta.setdocmeta!(XmlStructWriter, :DocTestSetup, :(using XmlStructWriter); recursive = true)

makedocs(;
    modules = [XmlStructWriter],
    authors = "ASML",
    repo = "https://github.com/ASML-Labs/XmlStructTools.jl/XmlStructWriter.jl/blob/{commit}{path}#{line}",
    sitename = "XmlStructWriter.jl",
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", "false") == "true", edit_link = "main", assets = String[]),
    pages = ["Home" => "index.md", "Docstrings" => "docstrings.md"],
)

deploydocs(repo = "github.com/ASML-Labs/XmlStructTools.jl/XmlStructWriter.jl.git")

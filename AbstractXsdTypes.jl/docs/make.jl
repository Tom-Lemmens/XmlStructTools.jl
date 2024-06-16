using AbstractXsdTypes
using Documenter

makedocs(;
    modules = [AbstractXsdTypes],
    repo = Remotes.GitHub("Tom-Lemmens", "XmlStructTools.jl"),
    sitename = "AbstractXsdTypes.jl",
    pages = ["Home" => "index.md", "Docstrings" => "docstrings.md"],
)

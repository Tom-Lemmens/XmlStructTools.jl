using XsdToStruct
using Documenter

makedocs(;
    modules = [XsdToStruct],
    repo = Remotes.GitHub("Tom-Lemmens", "XmlStructTools.jl"),
    sitename = "XsdToStruct.jl",
    pages = ["Home" => "index.md", "Docstrings" => "docstrings.md"],
)

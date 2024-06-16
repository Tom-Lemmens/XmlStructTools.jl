using XmlStructLoader
using Documenter

makedocs(;
    modules = [XmlStructLoader],
    repo = Remotes.GitHub("Tom-Lemmens", "XmlStructTools.jl"),
    sitename = "XmlStructLoader.jl",
    pages = ["Home" => "index.md", "Docstrings" => "docstrings.md"],
)

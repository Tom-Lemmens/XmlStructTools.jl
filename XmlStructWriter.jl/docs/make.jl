using XmlStructWriter
using Documenter

makedocs(;
    modules = [XmlStructWriter],
    repo = Remotes.GitHub("Tom-Lemmens", "XmlStructTools.jl"),
    sitename = "XmlStructWriter.jl",
    pages = ["Home" => "index.md", "Docstrings" => "docstrings.md"],
)

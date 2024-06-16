using XmlStructLoader
using Documenter

repo = Remotes.GitHub("Tom-Lemmens", "XmlStructLoader.jl")

makedocs(;
    modules = [XmlStructLoader],
    repo = repo,
    sitename = "XmlStructLoader.jl",
    pages = ["Home" => "index.md", "Docstrings" => "docstrings.md"],
)

deploydocs(
    repo=repo,
    dirname="XmlStructLoader.jl",
    tag_prefix="XmlStructLoader.jl-",
)

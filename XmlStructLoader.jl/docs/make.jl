using XmlStructLoader
using Documenter

repo = Remotes.GitHub("Tom-Lemmens", "XmlStructTools.jl")

makedocs(;
    modules = [XmlStructLoader],
    repo = repo,
    sitename = "XmlStructLoader.jl",
    pages = ["Home" => "index.md", "Docstrings" => "docstrings.md"],
)

deploydocs(
    repo="github.com/$(repo.user)/$(repo.repo)",
    dirname="XmlStructLoader.jl",
    tag_prefix="XmlStructLoader.jl-",
)

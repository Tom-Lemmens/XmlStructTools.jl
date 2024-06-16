using AbstractXsdTypes
using Documenter

repo = Remotes.GitHub("Tom-Lemmens", "XmlStructTools.jl")

makedocs(;
    modules = [AbstractXsdTypes],
    repo = repo,
    sitename = "AbstractXsdTypes.jl",
    pages = ["Home" => "index.md", "Docstrings" => "docstrings.md"],
)

deploydocs(
    repo="github.com/$(repo.user)/$(repo.repo)",
    dirname="AbstractXsdTypes.jl",
    tag_prefix="AbstractXsdTypes.jl-",
)

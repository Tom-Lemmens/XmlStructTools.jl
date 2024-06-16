using AbstractXsdTypes
using Documenter

repo = Remotes.GitHub("Tom-Lemmens", "AbstractXsdTypes.jl")

makedocs(;
    modules = [AbstractXsdTypes],
    repo = repo,
    sitename = "AbstractXsdTypes.jl",
    pages = ["Home" => "index.md", "Docstrings" => "docstrings.md"],
)

deploydocs(
    repo=repo,
    target="AbstractXsdTypes.jl"
)

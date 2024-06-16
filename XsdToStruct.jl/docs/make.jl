using XsdToStruct
using Documenter

repo = Remotes.GitHub("Tom-Lemmens", "XsdToStruct.jl")

makedocs(;
    modules = [XsdToStruct],
    repo = repo,
    sitename = "XsdToStruct.jl",
    pages = ["Home" => "index.md", "Docstrings" => "docstrings.md"],
)

deploydocs(
    repo=repo,
    dirname="XsdToStruct.jl",
    tag_prefix="XsdToStruct.jl-",
)

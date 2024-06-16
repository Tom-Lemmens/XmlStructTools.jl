using XsdToStruct
using Documenter

repo = Remotes.GitHub("Tom-Lemmens", "XmlStructTools.jl")

makedocs(;
    modules = [XsdToStruct],
    repo = repo,
    sitename = "XsdToStruct.jl",
    pages = ["Home" => "index.md", "Docstrings" => "docstrings.md"],
)

deploydocs(
    repo="github.com/$(repo.user)/$(repo.repo)",
    dirname="XsdToStruct.jl",
    tag_prefix="XsdToStruct.jl-",
)

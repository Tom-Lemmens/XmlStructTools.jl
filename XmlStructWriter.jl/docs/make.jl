using XmlStructWriter
using Documenter

repo = Remotes.GitHub("Tom-Lemmens", "XmlStructWriter.jl")

makedocs(;
    modules = [XmlStructWriter],
    repo = repo,
    sitename = "XmlStructWriter.jl",
    pages = ["Home" => "index.md", "Docstrings" => "docstrings.md"],
)

deploydocs(
    repo="github.com/$(repo.user)/$(repo.repo)",
    dirname="XmlStructWriter.jl",
    tag_prefix="XmlStructWriter.jl-",
)

using Documenter

repo = Remotes.GitHub("Tom-Lemmens", "XmlStructTools.jl")

makedocs(;
    repo = repo,
    sitename = "XmlStructTools.jl",
    pages = ["Home" => "index.md"],
)

deploydocs(
    repo="github.com/$(repo.user)/$(repo.repo)",
)

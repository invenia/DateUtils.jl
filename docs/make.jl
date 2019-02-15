using DateUtils, Documenter

makedocs(
    modules = [DateUtils],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    pages = [
        "Home" => "index.md",
    ],
    repo = "https://gitlab.invenia.ca/invenia/DateUtils.jl/blob/{commit}{path}#L{line}",
    sitename = "DateUtils.jl",
    authors = "Curtis Vogt",
    assets = ["assets/invenia.css"],
    checkdocs = :none,
    strict = true,
)

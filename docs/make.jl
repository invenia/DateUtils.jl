using Documenter, DateUtils

makedocs(
    modules = [DateUtils],
    format = :html,
    pages = [],
    repo = "https://gitlab.invenia.ca/invenia/DateUtils.jl/blob/{commit}{path}#L{line}",
    sitename = "DateUtils.jl",
    authors = "Curtis Vogt",
    assets = ["assets/invenia.css"],
)

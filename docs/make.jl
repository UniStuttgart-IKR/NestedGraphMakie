using Documenter, NestedGraphs, NestedGraphMakie

makedocs(sitename="NestedGraphMakie.jl",
    pages = [
        "Introduction" => "index.md",
        "API" => "API.md"
    ])

deploydocs(
    repo = "github.com/UniStuttgart-IKR/NestedGraphMakie.jl.git",
)

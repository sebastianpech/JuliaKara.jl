using Documenter, Kara

makedocs(
    format = :html,
    sitename = "Kara.jl",
    pages = [
        "index.md",
        "Submodules" => [
            "actorsworld.md"
        ]
    ]
)

deploydocs(
    repo = "github.com/sebastianpech/Kara.jl.git",
    target = "build",
    julia = "0.6",
    deps = nothing,
    make = nothing,
)

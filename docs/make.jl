using Documenter, JuliaKara

makedocs(
    format = :html,
    sitename = "JuliaKara.jl",
    pages = [
        "index.md",
        "Submodules" => [
            "actorsworld.md"
        ]
    ]
)

deploydocs(
    repo = "sebastianpech/JuliaKara.jl",
    target = "build",
    julia = "0.6",
    deps = nothing,
    make = nothing,
    osname= "osx"
)

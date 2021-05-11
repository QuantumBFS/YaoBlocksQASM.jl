using YaoBlocksQASM
using Documenter

DocMeta.setdocmeta!(YaoBlocksQASM, :DocTestSetup, :(using YaoBlocksQASM); recursive=true)

makedocs(;
    modules=[YaoBlocksQASM],
    authors="Arsh Sharma",
    repo="https://github.com/Sov-trotter/YaoBlocksQASM.jl/blob/{commit}{path}#{line}",
    sitename="YaoBlocksQASM.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Sov-trotter.github.io/YaoBlocksQASM.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Sov-trotter/YaoBlocksQASM.jl",
)

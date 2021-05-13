using YaoBlocksQASM, DocThemeIndigo
using Documenter
indigo = DocThemeIndigo.install(YaoBlocksQASM)

makedocs(;
    modules=[YaoBlocksQASM],
    authors="Arsh Sharma",
    repo="https://github.com/QuantumBFS/YaoBlocksQASM.jl/blob/{commit}{path}#{line}",
    sitename="YaoBlocksQASM.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://QuantumBFS.github.io/YaoBlocksQASM.jl",
        assets=String[],
    ),
    pages=[
        "Quickstart" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/QuantumBFS/YaoBlocksQASM.jl",devbranch = "main",
)

using AISCSteelApp
using Documenter

DocMeta.setdocmeta!(AISCSteelApp, :DocTestSetup, :(using AISCSteelApp); recursive=true)

makedocs(;
    modules=[AISCSteelApp],
    authors="Cole Miller",
    sitename="AISCSteelApp.jl",
    format=Documenter.HTML(;
        canonical="https://co1emi11er2.github.io/AISCSteelApp.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/co1emi11er2/AISCSteelApp.jl",
    devbranch="master",
)

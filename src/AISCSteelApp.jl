module AISCSteelApp

using Term
using REPL.TerminalMenus
using Term.LiveWidgets

const SHAPE_OPTIONS = ["WShape", "LShape", "WTShape", "Exit"]
include("WShape/WShape.jl")

function _print_usage(io::IO=stdout)
    println(io, "aisc-wshape - calculate capacities of a rolled wshape member")
    println(io)
    println(io, "Usage:")
    println(io, "  aisc-wshape [options] <wshape> <Lb>")
    println(io)
    println(io, "Options:")
    # println(io, "  --output-exe <name>         Output native executable (name only)")
    # println(io, "  --output-lib <path>         Output shared library (lib)")
    # println(io, "  --output-sysimage <path>    Output shared library (sysimage)")
    # println(io, "  --output-o <path>           Output object archive (default for linking)")
    # println(io, "  --output-bc <path>          Output LLVM bitcode archive")
    # println(io, "  --project <path>            Project to instantiate/precompile")
    # println(io, "  --bundle <dir>              Bundle libjulia, stdlibs, and artifacts")
    # println(io, "  --privatize                 Privatize bundled libjulia (Unix)")
    # println(io, "  --trim[=mode]               Strip IR/metadata (e.g. --trim=safe)")
    # println(io, "  --compile-ccallable         Export ccallable entrypoints")
    # println(io, "  --export-abi <file>         Emit type / function information for the ABI (in JSON format)")
    # println(io, "  --experimental              Forwarded to Julia (needed for --trim)")
    # println(io, "  --verbose                   Print commands and timings")
    println(io, "  --version                   Print juliac and julia version")
    println(io, "  -h, --help                  Show this help")
    println(io)
    println(io, "Examples:")
    println(io, "  aisc-wshape W10x12 10")
end

function _print_version(io::IO=stdout)
    println(io, "juliac version $(pkgversion(AISCSteelApp)), julia version $(VERSION)")
end

function shapes_mode_loop()
    
    menu = SimpleMenu(SHAPE_OPTIONS ; active_style="blue")
    while true
        println(@yellow "Select Shape Mode:")
        choice = SHAPE_OPTIONS[menu |> App |> play]

        if choice == "WShape"
            println(@blue "WShape")

            WShape.interactive_mode_loop()
        elseif choice == "LShape"
            println(@blue "LShape")

            println("not implemented yet")
        elseif choice == "WTShape"
            println(@blue "WTShape")

            println("not implemented yet")
        elseif choice == "Exit"
            println(@blue "Exit")

            println(@green "Exiting aisc. Goodbye!")
            break
        end
    end
end

function _main_cli(args::Vector{String}; io::IO=stdout)

    if isempty(args)

        shapes_mode_loop()
        return
    elseif any(a -> a == "-h" || a == "--help", args)
        _print_usage(io)
        return
    elseif "--version" in args
        _print_version(io)
        return
    end
    return
end


function (@main)(ARGS)
    _main_cli(ARGS)
end

end

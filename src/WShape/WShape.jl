module WShape
using Term
using REPL.TerminalMenus
using Term.LiveWidgets
import AISCSteel.Shapes.IShapes.RolledIShapes as RIS
using StructuralUnits

const MODE_OPTIONS = ["Specific Shapes", "Optimizations", "Exit"]
const CAPACITY_OPTIONS = ["Flexure", "Compression", "Exit"]

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

function _main_cli(args::Vector{String}; io::IO=stdout)

    if isempty(args)

        println(io, @yellow "Please provide the shape:")
        print(io, @blue "WShape (e.g., W10x12): ")
        wshape_input = readline()
        wshape = RIS.WShape(wshape_input)

        menu = SimpleMenu(CAPACITY_OPTIONS; active_style="blue")
        while true
            println(io, @yellow "\nSelect Capacity Calculation Type:")
            choice = CAPACITY_OPTIONS[menu |> App |> play]

            if choice == "Flexure"
                println(io, @blue "Flexure")
                println(io, @yellow "Please provide the following inputs:")
                print(io, @blue "Unbraced Length Lb (in feet): ")
                Lb_input = readline()
                L_b = parse(Float64, Lb_input)*ft
                _flexure(wshape, L_b; io)
            elseif choice == "Compression"
                println(io, @yellow "Selected capacity type is not yet implemented. Exiting.")
                break
            else
                println(io, @yellow "Exiting.")
                break
            end
        end
        return
    elseif any(a -> a == "-h" || a == "--help", args)
        _print_usage(io)
        return
    elseif "--version" in args
        _print_version(io)
        return
    end
    wshape = RIS.WShape(args[1])
    L_b = parse(Float64, args[2])*ft
    _flexure(wshape, L_b)
end

function _flexure(wshape::RIS.WShape, L_b::typeof(1.0ft); io::IO=stdout)
    ϕM_n = 0.9*RIS.Flexure.calc_Mnx(wshape, L_b)
    # ϕM_n_text = @style "$(round(kip*ft, ϕM_n, sigdigits=3))" blue bold underline
    print(io, @yellow "Flexure Capacity: ")
    tprintln(io, "{red} $(round(kip*ft, ϕM_n, sigdigits=3)) {/red}")
    return
end


function (@main)(ARGS)
    _main_cli(ARGS)
end

end

include("Specific_Shapes/specific_shapes.jl")
include("Optimizations/optimizations.jl")

function interactive_mode_loop()
    menu = SimpleMenu(MODE_OPTIONS; active_style="blue")
    while true
        println(@yellow "Select Mode:")
        choice = MODE_OPTIONS[menu |> App |> play]

        if choice == "Specific Shapes"
            println(@blue "Specific Shapes")

            specific_shapes_loop()
        elseif choice == "Optimizations"
            println(@blue "Optimizations")

            optimizations_loop()
        elseif choice == "Exit"
            println(@blue "Exit")

            println(@green "Exiting aisc-wshape. Goodbye!")
            break
        end
    end
end

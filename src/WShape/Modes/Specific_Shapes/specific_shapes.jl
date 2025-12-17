function specific_shapes_loop(; io::IO=stdout)
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
            println(io, @blue "Compression")
            println(io, @yellow "Please provide the following inputs:")
            print(io, @blue "Effective Length Lcx, Lcy (in feet)(e.g., 10, 20, 20): ")
            Lc_input = readline()
            L_cx, L_cy = parse.(Float64, split(Lc_input, ','))*ft
            _compression(wshape, L_cx, L_cy; io)
        else
            println(io, @yellow "Exiting.")
            break
        end
    end
end

function _flexure(wshape::RIS.WShape, L_b::typeof(1.0ft); io::IO=stdout)
    ϕM_n = 0.9*RIS.Flexure.calc_Mnx(wshape, L_b)
    # ϕM_n_text = @style "$(round(kip*ft, ϕM_n, sigdigits=3))" blue bold underline
    print(io, @yellow "Flexure Capacity: ")
    tprintln(io, "{red} $(round(kip*ft, ϕM_n, sigdigits=3)) {/red}")
    return
end

function _compression(wshape::RIS.WShape, L_cx::typeof(1.0ft), L_cy::typeof(1.0ft); io::IO=stdout)
    ϕP_n = 0.9*RIS.Compression.calc_Pn(wshape, L_cx, L_cy)
    # ϕM_n_text = @style "$(round(kip*ft, ϕM_n, sigdigits=3))" blue bold underline
    print(io, @yellow "Compression Capacity: ")
    tprintln(io, "{red} $(round(kip, ϕP_n, sigdigits=3)) {/red}")
    return
end
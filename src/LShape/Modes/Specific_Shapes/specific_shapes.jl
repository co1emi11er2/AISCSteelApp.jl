function specific_shapes_loop(; io::IO=stdout)
    println(io, @yellow "Please provide the shape:")
    print(io, @blue "LShape (e.g., L8x8x1/2): ")
    lshape_input = readline()
    lshape = LS.LShape(lshape_input)

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

            print(io, @blue "Restraint Type (fully_restrained, unrestrained, or at_max_moment_only): ")
            restraint_type_input = readline()
            restraint_type = Symbol(restraint_type_input)

            print(io, @blue "Bending Direction (+x, -x, +y, -y): ")
            bending_direction = readline()

            
            _flexure(lshape, L_b, restraint_type, bending_direction; io)
        elseif choice == "Compression"
            println(io, @blue "Compression")
            println(io, @yellow "Please provide the following inputs:")

            print(io, @blue "Length of member between work points L (in feet)(e.g., 10): ")
            L_input = readline()
            L = parse(Float64, L_input)*ft

            if lshape.b == lshape.d
                leg_connected = :long
            else
                print(io, @blue "Leg that is connected (short, long): ")
                leg_connected_input = readline()
                leg_connected = Symbol(leg_connected_input)
            end

            _compression(lshape, L, leg_connected; io)
        else
            println(io, @yellow "Exiting.")
            break
        end
    end
end

function _flexure(lshape::LS.LShape, L_b::typeof(1.0ft), restraint_type::Symbol, bending_direction::String; io::IO=stdout)
    C_b = 1.0

    if bending_direction == "+x"
        ϕM_n = 0.9*LS.Flexure.calc_positive_Mnx(lshape, L_b, restraint_type, C_b)
    elseif bending_direction == "-x"
        ϕM_n = 0.9*LS.Flexure.calc_negative_Mnx(lshape, L_b, restraint_type, C_b)
    elseif bending_direction == "+y"
        ϕM_n = 0.9*LS.Flexure.calc_positive_Mny(lshape, L_b, restraint_type, C_b)
    elseif bending_direction == "-y"
        ϕM_n = 0.9*LS.Flexure.calc_negative_Mny(lshape, L_b, restraint_type, C_b)
    else
        error("Invalid bending direction. Please enter +x, -x, +y, or -y.")
    end

    print(io, @yellow "Flexure Capacity: ")
    tprintln(io, "{red} $(round(kip*ft, ϕM_n, sigdigits=3)) {/red}")
    return
end

function _compression(lshape::LS.LShape, L::typeof(1.0ft), leg_connected::Symbol; io::IO=stdout)
    
    ϕP_n = 0.9*LS.Compression.calc_Pn(lshape, leg_connected, L)
    print(io, @yellow "Compression Capacity: ")
    tprintln(io, "{red} $(round(kip, ϕP_n, sigdigits=3)) {/red}")
    return
end

function optimizations_loop(; io::IO=stdout)
    lshapes = aisc_database(LS.LShape) do lshapes
        sort!(lshapes, :weight)
    end
    
    menu = SimpleMenu(CAPACITY_OPTIONS; active_style="blue")
    while true
        println(io, @yellow "\nSelect Capacity Calculation Type:")
        choice = CAPACITY_OPTIONS[menu |> App |> play]

        if choice == "Flexure"
            println(io, @blue "Flexure")

            # Get user input for flexure optimization
            println(io, @yellow "Please provide the following inputs:")

            # unbraced length
            print(io, @blue "Unbraced Length Lb (in feet): ")
            Lb_input = readline()
            L_b = parse(Float64, Lb_input)*ft

            # bending direction
            print(io, @blue "Bending Direction (+x, -x, +y, -y): ")
            bending_direction = readline()

            # moment demand
            print(io, @blue "Moment Demand Mu (in kip-ft): ")
            Mu_input = readline()
            M_u = parse(Float64, Mu_input)*kip*ft

            # restraint type
            print(io, @blue "Restraint Type (fully_restrained, unrestrained, or at_max_moment_only): ")
            restraint_type_input = readline()
            restraint_type = Symbol(restraint_type_input)

            # number of lightest shapes to display
            print(io, @blue "Number of lightest shapes to display: ")
            n_input = readline()
            n_shapes = parse(Int, n_input)

            _optimum_flexure(lshapes, L_b, M_u, restraint_type, bending_direction, n_shapes; io)
        elseif choice == "Compression"
            # Get user input for flexure optimization
            println(io, @yellow "Please provide the following inputs:")

            # length of member between work points
            print(io, @blue "Length of member between work points L (in feet)(e.g., 10): ")
            L_input = readline()
            L = parse(Float64, L_input)*ft

            # leg connected
            if lshape.b == lshape.d
                leg_connected = :long
            else
                print(io, @blue "Leg that is connected (short, long): ")
                leg_connected_input = readline()
                leg_connected = Symbol(leg_connected_input)
            end

            # compressive demand
            print(io, @blue "Compressive Demand Pu (in kip): ")
            Pu_input = readline()
            P_u = parse(Float64, Pu_input)*kip

            # number of lightest shapes to display
            print(io, @blue "Number of lightest shapes to display: ")
            n_input = readline()
            n_shapes = parse(Int, n_input)

            _optimum_compression(lshapes, L, P_u, leg_connected, n_shapes; io)
        else
            println(io, @yellow "Exiting.")
            break
        end
    end
end

function _optimum_flexure(lshapes, L_b, M_u, restraint_type, bending_direction, n_shapes; io::IO=stdout)

    C_b = 1.0

    shapes = String[]
    weights = Float64[]
    M_us = Float64[]
    ϕM_ns = Float64[]
    DCRs = Float64[]

    if bending_direction == "+x"
        calc_Mn = LS.Flexure.calc_positive_Mnx
    elseif bending_direction == "-x"
        calc_Mn = LS.Flexure.calc_negative_Mnx
    elseif bending_direction == "+y"
        calc_Mn = LS.Flexure.calc_positive_Mny
    elseif bending_direction == "-y"
        calc_Mn = LS.Flexure.calc_negative_Mny
    else
        error("Invalid bending direction. Please enter +x, -x, +y, or -y.")
    end
    
    count = 0
    for l_data in eachrow(lshapes)
        l = LS.LShape(l_data.shape)
        ϕM_n = calc_Mn(l, L_b, restraint_type, C_b) * 0.9
        if ϕM_n >= M_u
            push!(shapes, l_data.shape)
            push!(weights, l.weight.val)
            M_u_round = round(kip*ft, M_u, sigdigits=3)
            push!(M_us, M_u_round.val)
            ϕM_n_round = round(kip*ft, ϕM_n, sigdigits=3)
            push!(ϕM_ns, ϕM_n_round.val)
            DCR = round( M_u / ϕM_n, sigdigits=3)
            push!(DCRs, DCR)
            count += 1
            if count >= n_shapes
                break
            end
        end
    end

    df = DataFrame(
        "Shape" => shapes,
        "Weight (lb/ft)" => weights,
        "M_u (kip-ft)" => M_us,
        "ϕM_n (kip-ft)" => ϕM_ns,
        "DCR" => DCRs,
    )
    println(io, @yellow "\nOptimum Shapes for Flexure Capacity:")
    pt = pretty_table(df)
    return
end


function _optimum_compression(lshapes, L, P_u, leg_connected, n_shapes; io::IO=stdout)

    shapes = String[]
    weights = Float64[]
    P_us = Float64[]
    ϕP_ns = Float64[]
    DCRs = Float64[]
    
    count = 0
    for l_data in eachrow(lshapes)
        l = LS.LShape(l_data.shape)
        ϕP_n = LS.Compression.calc_Pn(l, leg_connected, L) * 0.9
        if ϕP_n >= P_u
            push!(shapes, l_data.shape)
            push!(weights, l.weight.val)
            P_u_round = round(kip, P_u, sigdigits=3)
            push!(P_us, P_u_round.val)
            ϕP_n_round = round(kip, ϕP_n, sigdigits=3)
            push!(ϕP_ns, ϕP_n_round.val)
            DCR = round( P_u / ϕP_n, sigdigits=3)
            push!(DCRs, DCR)
            count += 1
            if count >= n_shapes
                break
            end
        end
    end

    df = DataFrame(
        "Shape" => shapes,
        "Weight (lb/ft)" => weights,
        "P_u (kip)" => P_us,
        "ϕP_n (kip)" => ϕP_ns,
        "DCR" => DCRs,
    )
    println(io, @yellow "\nOptimum Shapes for Flexure Capacity:")
    pt = pretty_table(df)
    return
end

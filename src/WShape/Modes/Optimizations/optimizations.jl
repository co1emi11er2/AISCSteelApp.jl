function optimizations_loop(; io::IO=stdout)
    wshapes = aisc_database(RIS.WShape) do wshapes
        sort!(wshapes, :weight)
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

            # moment demand
            print(io, @blue "Moment Demand Mu (in kip-ft): ")
            Mu_input = readline()
            M_u = parse(Float64, Mu_input)*kip*ft

            # number of lightest shapes to display
            print(io, @blue "Number of lightest shapes to display: ")
            n_input = readline()
            n_shapes = parse(Int, n_input)

            _optimum_flexure(wshapes, L_b, M_u, n_shapes; io)
        elseif choice == "Compression"
            # Get user input for flexure optimization
            println(io, @yellow "Please provide the following inputs:")

            # unbraced length
            print(io, @blue "Effective Length Lcx, Lcy (in feet)(e.g., 10, 20, 20): ")
            Lc_input = readline()
            L_cx, L_cy = parse.(Float64, split(Lc_input, ','))*ft

            # compressive demand
            print(io, @blue "Compressive Demand Pu (in kip): ")
            Pu_input = readline()
            P_u = parse(Float64, Pu_input)*kip

            # number of lightest shapes to display
            print(io, @blue "Number of lightest shapes to display: ")
            n_input = readline()
            n_shapes = parse(Int, n_input)

            _optimum_compression(wshapes, L_cx, L_cy, P_u, n_shapes; io)
        else
            println(io, @yellow "Exiting.")
            break
        end
    end
end

function _optimum_flexure(wshapes, L_b, M_u, n_shapes; io::IO=stdout)

    shapes = String[]
    weights = Float64[]
    M_us = Float64[]
    ϕM_ns = Float64[]
    DCRs = Float64[]
    
    count = 0
    for w_data in eachrow(wshapes)
        w = RIS.WShape(w_data.shape)
        ϕM_n = RIS.Flexure.calc_Mnx(w, L_b) * 0.9
        if ϕM_n >= M_u
            push!(shapes, w_data.shape)
            push!(weights, w.weight.val)
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


function _optimum_compression(wshapes, L_cx, L_cy, P_u, n_shapes; io::IO=stdout)

    shapes = String[]
    weights = Float64[]
    P_us = Float64[]
    ϕP_ns = Float64[]
    DCRs = Float64[]
    
    count = 0
    for w_data in eachrow(wshapes)
        w = RIS.WShape(w_data.shape)
        ϕP_n = RIS.Compression.calc_Pn(w, L_cx, L_cy) * 0.9
        if ϕP_n >= P_u
            push!(shapes, w_data.shape)
            push!(weights, w.weight.val)
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

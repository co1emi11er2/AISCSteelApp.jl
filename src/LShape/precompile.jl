using PrecompileTools: @setup_workload, @compile_workload


@setup_workload begin
    # Putting some things in `@setup_workload` instead of `@compile_workload` can reduce the size of the
    # precompile file and potentially make loading faster.
    @compile_workload begin
        # all calls in this block will be precompiled, regardless of whether
        # they belong to your package or not (on Julia 1.8 and higher)


        l = LS.LShape("L8x8x1/2")
        lshapes = aisc_database(LS.LShape) do lshapes
            sort!(lshapes, :weight)
        end
        L_b = 10ft
        M_u = 100kip*ft
        restraint_type = :fully_restrained
        bending_direction = "+x"
        n_shapes = 10
        _optimum_flexure(lshapes, L_b, M_u, restraint_type, bending_direction, n_shapes)

        L = 10.0ft
        leg_connected = :long
        P_u = 200.0kip
        n_shapes = 10
        _optimum_compression(lshapes, L, P_u, leg_connected, n_shapes)
    end
end

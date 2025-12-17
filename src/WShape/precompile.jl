using PrecompileTools: @setup_workload, @compile_workload


@setup_workload begin
    # Putting some things in `@setup_workload` instead of `@compile_workload` can reduce the size of the
    # precompile file and potentially make loading faster.
    @compile_workload begin
        # all calls in this block will be precompiled, regardless of whether
        # they belong to your package or not (on Julia 1.8 and higher)
        menu = SimpleMenu(CAPACITY_OPTIONS; active_style="blue")
        choice = menu |> App


        menu = SimpleMenu(MODE_OPTIONS; active_style="blue")
        choice = menu |> App

        w = RIS.WShape("W10x12")
        wshapes = aisc_database(RIS.WShape) do wshapes
            sort!(wshapes, :weight)
        end
        L_b = 10ft
        M_u = 500kip*ft
        n_shapes = 10
        _optimum_flexure(wshapes, L_b, M_u, n_shapes)

        L_cx = 10.0ft
        L_cy = 20.0ft
        P_u = 200.0kip
        n_shapes = 10
        _optimum_compression(wshapes, L_cx, L_cy, P_u, n_shapes)
    end
end

"""
    ngraphplot(ng::NestedGraph)
    ngraphplot!(ax, ng::NestedGraph)

Plots a NestedGraph. Actually decorates `GraphMakie.graphplot` with some extra features.

## Attributes
- `colors=automatic`: Vector of colors for the 1st-level subgraphs
- `multilayer=false`: Plot 1st-level subgraphs in a multilayer fashion
- `multilayer_dist=automatic`: how far away should the layer of the graph be
- `fold_graphs=[Int[]]`: choose which graphs not to unfold
- `show_subgraph_regions=false` depicts all subgraphs in the plot
"""
@recipe(NGraphPlot, ngraph) do scene
    Attributes(
        colors = Makie.automatic,
        multilayer = false,
        multilayer_dist = Makie.automatic,
        layout = Spring(),
        fold_graphs = [Int[]],
        show_subgraph_regions = false,
    )
end

function Makie.plot!(cgp::NGraphPlot)
    ngraph = cgp[:ngraph]
    nodecolors = @lift begin
        ngr = $(ngraph)
        nodecolors = Vector{Color}()
        if $(cgp.colors) isa Vector
            return [$(cgp.colors)[ngr.vmap[verts][1]] for verts in vertices(ngr)]
        else
            if $(cgp.show_subgraph_regions)
#                distcolors = Colors.distinguishable_colors(NestedGraphs.gettotalsubgraphs(ngr)  + 3, [RGB(1,1,1), RGB(0,0,0)])[3:end]
                distcolors = Colors.distinguishable_colors(NestedGraphs.gettotalsubgraphs(ngr), [RGB(1,1,1), RGB(0,0,0)]; dropseed=true)
            else
                distcolors = Colors.distinguishable_colors(length(ngr.grv))
                [distcolors[ngr.vmap[verts][1]] for verts in vertices(ngr)]
            end
        end
    end

    # TODO use Observables
    if cgp.multilayer[]
        nothing
        sg, mlvertices = NestedGraphs.getmlsquashedgraph(ngraph[])
        flatgr = ngraph[].flatgr

        vposmlo = @lift begin
            vpos = $(cgp.layout)(adjacency_matrix(sg))
        end

        multilayerdisto = @lift begin
            if $(cgp.multilayer_dist) == Makie.automatic
                getmaximumydist($(vposmlo))
            else
                1.1*$(cgp.multilayer_dist)
            end
        end

        fixlays = [let
            mlvertexind = findfirst(mlverts -> v ∈ mlverts, mlvertices)
            fixlayout = vposmlo[][mlvertexind] .+ Point2{Float64}([0, (vm[1]-1)*multilayerdisto[]])
        end for (v,vm) in enumerate(ngraph[].vmap)]

        solidvsdashedgestyle = [NestedGraphs.issamesubgraph(ngraph[], e) ? :solid : :dash for e in edges(ngraph[])]
        GraphMakie.graphplot!(cgp, flatgr; node_color=nodecolors[], cgp.attributes..., layout=fixedlayout(fixlays), edge_plottype=:beziersegments, edge_attr=(linestyle=solidvsdashedgestyle, ) )
    elseif cgp.show_subgraph_regions[]
        subgraphs = NestedGraphs.getallsubgraphpaths(ngraph[])
        sort!(subgraphs, by=x->length(x))
        subverts = vertices.([ngraph[]], subgraphs)

        vposo = @lift begin
            vpos = $(cgp.layout)(adjacency_matrix(ngraph[].flatgr))
        end

        observations = [vposo[][verts] for verts in subverts] 
        dims = [ContinuousDim(), ContinuousDim()]
        x1_range = LinRange(minimum(getindex.(vposo[], 1)) - 0.50*getmaximumxdist(vposo[]), maximum(getindex.(vposo[], 1)) + 0.50*getmaximumxdist(vposo[]), 100)
        x2_range = LinRange(minimum(getindex.(vposo[], 2)) - 0.50*getmaximumydist(vposo[]), maximum(getindex.(vposo[], 2)) + 0.50*getmaximumydist(vposo[]), 100)
        x_grid = [[_x1, _x2] for _x1 in x1_range for _x2 in x2_range]
        bw = [0.8, 0.8]

        for i in eachindex(observations)
            kde = KDEMulti(dims, bw, Vector{Vector{Float64}}(observations[i]))
            y = [MultiKDE.pdf(kde, _x) for _x in x_grid]
            cr = RGBAf.(Colors.coloralpha.(to_colormap(range(color("white"), nodecolors[][i])), 1))
            contour_plot = contour!(cgp, getindex.(x_grid,1), getindex.(x_grid,2), y; levels=4, colormap=cr)
        end
        GraphMakie.graphplot!(cgp, ngraph[]; merge((node_color=:black,), NamedTuple(cgp.attributes))...)
    else
        GraphMakie.graphplot!(cgp, ngraph[]; merge((node_color=nodecolors,), NamedTuple(cgp.attributes))...)
    end
    return cgp
end

fixedlayout(layoutvec) = x -> layoutvec
getmaximumydist(vp::Vector{Point2{T}}) where T = [abs(y1-y2) for y1 in getindex.(vp, 2) for y2 in getindex.(vp,2)] |> maximum
getmaximumxdist(vp::Vector{Point2{T}}) where T = [abs(y1-y2) for y1 in getindex.(vp, 1) for y2 in getindex.(vp,1)] |> maximum

"""
    ngraphplot(ng::NestedGraph)
    ngraphplot!(ax, ng::NestedGraph)

Plots a NestedGraph. Actually decorates `GraphMakie.graphplot` with some extra features.

## Attributes
- `colors=automatic`: Vector of colors for the 1st-level subgraphs
- `multilayer=false`: Plot 1st-level subgraphs in a multilayer fashion
- `multilayer_dist=automatic`: how far away should the layer of the graph be
"""
@recipe(NGraphPlot, ngraph) do scene
    Attributes(
        colors = Makie.automatic,
        multilayer = false,
        multilayer_dist = Makie.automatic,
        layout = Spring()
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
            distcolors = Colors.distinguishable_colors(length(ngr.grv))
            return [distcolors[ngr.vmap[verts][1]] for verts in vertices(ngr)]
        end
    end

    # TODO use Observables
    if cgp.multilayer[]
        nothing
        sg, mlvertices = NestedGraphs.getmlsquashedgraph(ngraph[])
        flatgr = ngraph[].flatgr

        vposo = @lift begin
            vpos = $(cgp.layout)(adjacency_matrix(sg))
        end

        multilayerdisto = @lift begin
            if $(cgp.multilayer_dist) == Makie.automatic
                getmaximumydist($(vposo))
            else
                1.1*$(cgp.multilayer_dist)
            end
        end

        fixlays = [let
            mlvertexind = findfirst(mlverts -> v ∈ mlverts, mlvertices)
            fixlayout = vposo[][mlvertexind] .+ Point2{Float64}([0, (vm[1]-1)*multilayerdisto[]])
        end for (v,vm) in enumerate(ngraph[].vmap)]

        solidvsdashedgestyle = [NestedGraphs.issamesubgraph(ngraph[], e) ? :solid : :dash for e in edges(ngraph[])]
        GraphMakie.graphplot!(cgp, flatgr; node_color=nodecolors[], cgp.attributes..., layout=fixedlayout(fixlays), edge_plottype=:beziersegments, edge_attr=(linestyle=solidvsdashedgestyle, ) )
    else
        GraphMakie.graphplot!(cgp, ngraph[]; merge((node_color=nodecolors,), NamedTuple(cgp.attributes))...)
    end
    return cgp
end

fixedlayout(layoutvec) = x -> layoutvec
getmaximumydist(vp::Vector{Point2{T}}) where T = [abs(y1-y2) for y1 in getindex.(vp, 2) for y2 in getindex.(vp,2)] |> maximum

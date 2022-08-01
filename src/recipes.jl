@recipe(NGraphPlot, ngraph) do scene
    Attributes(
        colors = Makie.automatic
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
    # GraphMakie.graphplot!(cgp, cgp[:ngraph][]; merge((node_color=nodecolors,), NamedTuple(Makie.attributes_from(GraphMakie.GraphPlot, cgp)))...)
    GraphMakie.graphplot!(cgp, cgp[:ngraph][]; merge((node_color=nodecolors,), NamedTuple(cgp.attributes))...)
    return cgp
end
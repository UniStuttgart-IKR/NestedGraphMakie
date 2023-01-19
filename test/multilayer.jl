@testset "multilayer" begin
    layer1 = complete_graph(4)
    layer2 = barabasi_albert(4, 3; seed=123)
    layer3 = SimpleGraph(3)
    add_edge!(layer3, 1,2)
    add_edge!(layer3, 2,3)

    mlg = NestedGraph([layer1, layer2, layer3])

    for v in 1:(nv(layer2)-1)
        add_edge!(mlg, NestedEdge(1,v, 2,v))
    end
    for v in 1:(nv(layer3)-1)
        add_edge!(mlg, NestedEdge(2,v, 3,v))
    end
    add_edge!(mlg, NestedEdge(1,4, 3,3))

    f,_,_ = ngraphplot(mlg; multilayer=true, nlabels=repr.(mlg.vmap))
    counter = length(readdir(TMPDIR))
    save(joinpath(TMPDIR, "test-$(counter+1).png"), f)
end

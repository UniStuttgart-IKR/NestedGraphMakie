using Test, Graphs, NestedGraphs
using GraphMakie
using NestedGraphMakie, GLMakie

g1 = complete_graph(3)
g2 = complete_graph(3)
g3 = complete_graph(3)
g4 = complete_graph(4)
eds = [((1,1), (2,1)), ((3,2), (2,1)), ((3,3),(2,3)), ((1,1),(4,1))]
ng = NestedGraph([g1,g2,g3,g4], eds, both_ways=true)
ng1 = NestedGraph([g1,g2], [((1,1), (2,1))])
ng2 = NestedGraph([g3,g4], [((1,2), (2,2)), ((1,3), (2,3))])
ngm = NestedGraph([ng1, ng2], [((1,1),(2,1)), ((1,5),(2,2))], both_ways=true)
ngraphplot(ngm)

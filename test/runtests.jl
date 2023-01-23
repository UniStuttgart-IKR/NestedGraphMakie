using NestedGraphMakie, Graphs, NestedGraphs
using Test, TestSetExtensions, ReferenceTests, FileIO
using CairoMakie

TESTDIr = @__DIR__
ASSETSDIR = joinpath(@__DIR__, "../assets/")
TMPDIR = joinpath(ASSETSDIR, "tmp")
isdir(TMPDIR) && rm(TMPDIR; recursive=true)
mkdir(TMPDIR)

PSNR_THRESHOLD::Int = 30

@testset "NestedGraphMakie.jl" begin
    @includetests ["simple", "multilayer", "reftests"]
end


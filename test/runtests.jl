using NestedGraphMakie, Graphs, NestedGraphs
using Test, TestSetExtensions, ReferenceTests, FileIO
using CairoMakie

@testset "NestedGraphMakie.jl" begin
    TESTDIr = @__DIR__
    ASSETSDIR = joinpath(@__DIR__, "../assets/")
    TMPDIR = joinpath(ASSETSDIR, "tmp")
    isdir(TMPDIR) && rm(TMPDIR; recursive=true)
    mkdir(TMPDIR)

    PSNR_THRESHOLD::Int = 30

    @includetests ["simple", "multilayer", "reftests"]
end

